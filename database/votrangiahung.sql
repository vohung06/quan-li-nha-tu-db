--3. Truy vấn: Truy vấn với mệnh đề having (5 câu), Truy vấn sử dụng phép chia (4 câu)
--4. 1 thủ tục, 2 hàm, 2 trigger
--5. Tạo 1 người dùng và cấp quyền 

USE QLNT;

--Truy vấn với mệnh đề having (5 câu)
--1. Tìm tù nhân có từ 2 thân nhân trở lên
SELECT TN.MaTuNhan, TN.HoTen, COUNT(TNH.MaThanNhan) AS SoLuongThanNhan
FROM TUNHAN TN
JOIN THANNHAN TNH ON TNH.MaTuNhan = TN.MaTuNhan
GROUP BY TN.MaTuNhan, TN.HoTen
HAVING COUNT(TNH.MaThanNhan) >= 2;

--2. Tìm khu vực có số người giam giữ lớn hơn 8
SELECT KV.MaKV, KV.TenKV, SUM(PG.SoLuongHienTai) AS TongNguoi
FROM KHUVUC KV
JOIN PHONGGIAM PG ON PG.MaKV = KV.MaKV
GROUP BY KV.MaKV, KV.TenKV
HAVING SUM(PG.SoLuongHienTai) > 8;

--3. Tìm thông tin quản ngục phụ trách quản lí nhiều buổi cải tạo nhất
SELECT QN.MaQuanNguc, QN.TenQuanNguc, COUNT(*) AS SoBuoiPhuTrach
FROM QUANNGUC QN
JOIN CAITAO CT ON CT.MaQuanNgucPhuTrach = QN.MaQuanNguc
GROUP BY QN.MaQuanNguc, QN.TenQuanNguc
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM CAITAO
	GROUP BY CAITAO.MaQuanNgucPhuTrach
);

--4. Tìm tù nhân có số lần vi phạm lớn hơn trung bình số lần vi phạm của các tù nhân khác.
SELECT MaTuNhan, COUNT(*) AS SoLanViPham
FROM VIPHAMKYLUAT
GROUP BY MaTuNhan
HAVING COUNT(*) > (
	SELECT AVG(SoLan)
	FROM (
		SELECT COUNT(*) AS SoLan
		FROM VIPHAMKYLUAT
		GROUP BY MaTuNhan
	) AS TB
);

--5. Tìm tù nhân có từ 2 lần cải tạo đạt trở lên và lần cải tạo gần nhất diễn ra trong năm 2026
SELECT TN.MaTuNhan, TN.HoTen, COUNT(*) AS SoLanCaiTao
FROM TUNHAN TN
JOIN CAITAO CT ON CT.MaTuNhan = TN.MaTuNhan
WHERE CT.DanhGia = N'Tốt' OR CT.DanhGia = N'Khá'
GROUP BY TN.MaTuNhan, TN.HoTen
HAVING COUNT(*) >= 2 AND MAX(CT.NgayThucHien) > '2026-01-01';

--Truy vấn sử dụng phép chia (4 câu)

--Thủ tục (1 câu)
--Xây dựng thủ tục thực hiện chuyển phòng cho tù nhân có chức năng: cập nhật phòng mới, lưu lịch sử chuyển phòng
--và thay đổi số lượng tù nhân trong các phòng giam
CREATE PROC sp_ChuyenPhongTuNhan
	@MaTuNhan VARCHAR(10),
	@MaPhongMoi VARCHAR(10),
	@LiDo NVARCHAR(100)
AS
BEGIN
	DECLARE @MaPhongCu VARCHAR(10)
	DECLARE @MaLichSu VARCHAR(10)
	--Lấy mã phòng hiện tại
	SELECT @MaPhongCu = MaPhong
	FROM TUNHAN
	WHERE MaTuNhan = @MaTuNhan
	--Tạo mã lịch sử chuyển phòng mới
	SELECT @MaLichSu = 'LS' + RIGHT('000' + CAST(COUNT(*) + 1 AS VARCHAR), 3)
	FROM LICHSUCHUYENPHONG
	--Cập nhật phòng mới
	UPDATE TUNHAN
	SET MaPhong = @MaPhongMoi
	WHERE MaTuNhan = @MaTuNhan
	--Thêm lịch sử chuyển phòng
	INSERT INTO LICHSUCHUYENPHONG ([MaLichSu], [MaTuNhan], [MaPhongCu], [MaPhongMoi], [NgayChuyen], [LiDo])
	VALUES
	(@MaLichSu, @MaTuNhan, @MaPhongCu, @MaPhongMoi, GETDATE(), @LiDo)
	--Giảm số người phòng cũ
	UPDATE PHONGGIAM
	SET SoLuongHienTai = SoLuongHienTai - 1
	WHERE MaPhong = @MaPhongCu
	--Tăng số người phòng mới
	UPDATE PHONGGIAM
	SET SoLuongHienTai = SoLuongHienTai + 1
	WHERE MaPhong = @MaPhongMoi
END;

EXEC sp_ChuyenPhongTuNhan 'TN001', 'PB202', N'Chuyển sang khu mới';

--Hàm (2 câu)
--1. Xây dựng hàm trả về danh sách phòng giam thuộc một khu vực được truyền vào
CREATE FUNCTION fn_PHONGGIAM_TheoKV (@MaKV VARCHAR(10))
RETURNS TABLE
AS
RETURN (
	SELECT MaPhong, MaKV, SucChua, SoLuongHienTai, TrangThai
	FROM PHONGGIAM
	WHERE MaKV = @MaKV
);

SELECT *
FROM dbo.fn_PHONGGIAM_TheoKV('KVB');

--2. xây dựng hàm trả về bảng bao gồm thông tin của tội danh và số lượng tù nhân mang tội danh đó
CREATE FUNCTION fn_TOIDANH_ThongKe()
RETURNS @KetQua
TABLE (MaToiDanh VARCHAR(10), TenToiDanh NVARCHAR(40), SoLuongTuNhan INT)
AS
BEGIN
	INSERT INTO @KetQua
	SELECT TD.MaToiDanh, TD.TenToiDanh, COUNT(DISTINCT BA.MaTuNhan) AS SoLuongTuNhan
	FROM TOIDANH TD
	JOIN BANAN_TOIDANH BT ON BT.MaToiDanh = TD.MaToiDanh
	JOIN BANAN BA ON BA.MaBanAn = BT.MaBanAn
	GROUP BY TD.MaToiDanh, TD.TenToiDanh
	RETURN
END;

SELECT *
FROM dbo.fn_TOIDANH_ThongKe();
--Trigger (2 câu)
--Tạo 1 người dùng và cấp quyền
