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

--2. Tìm tù nhân có lần thăm nuôi gần nhất trong năm 2026
SELECT TN.MaTuNhan, TN.HoTen, MAX(TNU.NgayTham) AS LanThamGanNhat
FROM TUNHAN TN
JOIN THAMNUOI TNU ON TNU.MaTuNhan = TN.MaTuNhan
GROUP BY TN.MaTuNhan, TN.HoTen
HAVING MAX(TNU.NgayTham) >= '2026-01-01';

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


--Truy vấn sử dụng phép chia (4 câu)
--Thủ tục (1 câu)
--Hàm (2 câu)
--Trigger (2 câu)
--Tạo 1 người dùng và cấp quyền
