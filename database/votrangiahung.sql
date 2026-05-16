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
--Hàm (2 câu)
--Trigger (2 câu)
--Tạo 1 người dùng và cấp quyền
