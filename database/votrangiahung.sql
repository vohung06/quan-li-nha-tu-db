--3. Truy vấn: Truy vấn với mệnh đề having (5 câu), Truy vấn sử dụng phép chia (4 câu)
--4. 1 thủ tục, 2 hàm, 2 trigger
--5. Tạo 1 người dùng và cấp quyền 

USE QLNT;

--Truy vấn với mệnh đề having (5 câu)
--1. Tìm khu vực có số người giam giữ lớn hơn 8
SELECT MaKV, SUM(SoLuongHienTai) AS SoNguoi
FROM PHONGGIAM
GROUP BY MaKV
HAVING SUM(SoLuongHienTai) > 8;

--2. Tìm tù nhân có từ 2 thân nhân trở lên
SELECT TN.MaTuNhan, TN.HoTen, COUNT(TNH.MaThanNhan) AS SoLuongThanNhan
FROM TUNHAN TN
JOIN THANNHAN TNH ON TNH.MaTuNhan = TN.MaTuNhan
GROUP BY TN.MaTuNhan, TN.HoTen
HAVING COUNT(TNH.MaThanNhan) >= 2;

--3. Tìm tù nhân có từ 2 lần cải tạo đạt trở lên và lần cải tạo gần nhất diễn ra trong năm 2026
SELECT TN.MaTuNhan, TN.HoTen, COUNT(*) AS SoLanCaiTao
FROM TUNHAN TN
JOIN CAITAO CT ON CT.MaTuNhan = TN.MaTuNhan
WHERE CT.DanhGia = N'Tốt' OR CT.DanhGia = N'Khá'
GROUP BY TN.MaTuNhan, TN.HoTen
HAVING COUNT(*) >= 2 AND MAX(CT.NgayThucHien) > '2026-01-01';

--4. Tìm thông tin quản ngục phụ trách quản lí nhiều buổi cải tạo nhất
SELECT QN.MaQuanNguc, QN.TenQuanNguc, COUNT(*) AS SoBuoiPhuTrach
FROM QUANNGUC QN
JOIN CAITAO CT ON CT.MaQuanNgucPhuTrach = QN.MaQuanNguc
GROUP BY QN.MaQuanNguc, QN.TenQuanNguc
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM CAITAO
	GROUP BY CAITAO.MaQuanNgucPhuTrach
);

--5. Tìm tù nhân có số lần vi phạm lớn hơn trung bình số lần vi phạm của các tù nhân khác.
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

--Truy vấn sử dụng phép chia (4 câu)
--1. Tìm tù nhân có tham gia tất cả các công việc cải tạo.
SELECT MaTuNhan
FROM CAITAO
GROUP BY MaTuNhan
HAVING COUNT(DISTINCT MaCongViec) = (
	SELECT COUNT(*)
	FROM CONGVIEC
);

--2. Tìm quản ngục phụ trách ít nhất một ngày cải tạo của tất cả các tù nhân từng cải tạo. 
SELECT QN.MaQuanNguc
FROM QUANNGUC QN
WHERE NOT EXISTS (
	SELECT *
	FROM (
		SELECT DISTINCT MaTuNhan
		FROM CAITAO
	) T
	WHERE NOT EXISTS (
		SELECT *
		FROM CAITAO CT
		WHERE CT.MaQuanNgucPhuTrach = QN.MaQuanNguc AND CT.MaTuNhan = T.MaTuNhan
	)
);
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

--Xây dựng thủ tục thực hiện: hiển thị thông tin thân nhân dựa trên mã tù nhân truyền vào
CREATE PROC sp_THANNHAN_TuNhan @MaTN VARCHAR(10)
AS
BEGIN
	SELECT *
	FROM THANNHAN 
	WHERE MaTuNhan = @MaTN
END;

EXEC sp_THANNHAN_TuNhan 'TN010';

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

--2. Xây dựng hàm trả về bảng bao gồm thông tin của tội danh và số lượng tù nhân mang tội danh đó
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
--1. Tạo trigger sao cho: Khi thêm lịch thăm nuôi mới vào bảng LICHTHAMNUOI phải đảm bảo cách lần hẹn trước >= 100 ngày
IF EXISTS (SELECT NAME FROM SYSOBJECTS
WHERE NAME = 'trg_KiemTraLichThamNuoi' AND TYPE = 'tr')
DROP TRIGGER trg_KiemTraLichThamNuoi
GO
CREATE TRIGGER trg_KiemTraLichThamNuoi
ON LICHTHAMNUOI
FOR INSERT
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted i
		WHERE EXISTS (
			SELECT TOP 1 *
			FROM LICHTHAMNUOI L
			WHERE L.MaTuNhan = i.MaTuNhan
				AND L.NgayHen < i.NgayHen
				AND DATEDIFF(DAY, L.NgayHen, i.NgayHen) < 100
			ORDER BY L.NgayHen DESC
		)
	)
	BEGIN
		ROLLBACK
		RAISERROR(N'Lịch hẹn phải cách lần trước tối thiểu 100 ngày!',16,1)
	END
END;

INSERT INTO LICHTHAMNUOI([MaLich], [MaTuNhan], [MaThanNhan], [NgayHen], [TrangThai], [GhiChu])
VALUES ('LT021', 'TN018', 'TNH031', '2026-12-01', N'Chưa duyệt', NULL);

--2. Tạo trigger sao cho: Khi ngày hiện tại lớn hơn ngày kết thúc bản án, tự động cập nhật giá trị cho tù nhân được ra tù.
IF EXISTS (SELECT NAME FROM SYSOBJECTS
WHERE NAME = 'trg_CapNhatRaTu' AND TYPE = 'tr')
DROP TRIGGER trg_CapNhatRaTu
GO
CREATE TRIGGER trg_CapNhatRaTu
ON BANAN
FOR INSERT, UPDATE
AS
BEGIN
	UPDATE TN
	SET TN.NgayXuatTrai = GETDATE(), 
		TN.TrangThai = N'Đã mãn hạn',
		TN.MaPhong = NULL
	FROM TUNHAN TN
	JOIN inserted i ON i.MaTuNhan = TN.MaTuNhan
	WHERE GETDATE() > i.NgayKetThucDuKien
END;

BEGIN TRAN
UPDATE BANAN
SET NgayKetThucDuKien = '2026-01-01'
WHERE MaTuNhan = 'TN001';

SELECT *
FROM TUNHAN
WHERE MaTuNhan = 'TN001';
ROLLBACK;
--Tạo 1 người dùng và cấp quyền
--Tạo quyền với quản ngục bình thường (không phải Trưởng và phó khu)
CREATE LOGIN qn_thuong WITH PASSWORD = 'qn123456';	
USE QLNT;
CREATE USER qn_thuong_user FOR LOGIN qn_thuong;
GRANT SELECT, INSERT, UPDATE ON TUNHAN TO qn_thuong_user;
GRANT SELECT, INSERT, UPDATE ON THANNHAN TO qn_thuong_user;
GRANT SELECT, INSERT, UPDATE ON PHONGGIAM TO qn_thuong_user;
GRANT SELECT ON QUANNGUC TO qn_thuong_user;
