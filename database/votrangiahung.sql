--3. Truy vấn: Truy vấn với mệnh đề having (5 câu), Truy vấn sử dụng phép chia (4 câu)
--4. 1 thủ tục, 2 hàm, 2 trigger
--5. Tạo 1 người dùng và cấp quyền 

USE QLNT;

--Truy vấn với mệnh đề having (5 câu)
--1. Tìm những tù nhân có từ 2 thân nhân trở lên
SELECT TN.MaTuNhan, TN.HoTen, COUNT(TNH.MaThanNhan) AS SoLuongThanNhan
FROM TUNHAN TN
JOIN THANNHAN TNH ON TNH.MaTuNhan = TN.MaTuNhan
GROUP BY TN.MaTuNhan, TN.HoTen
HAVING COUNT(TNH.MaThanNhan) >= 2;



--Truy vấn sử dụng phép chia (4 câu)
--Thủ tục (1 câu)
--Hàm (2 câu)
--Trigger (2 câu)
--Tạo 1 người dùng và cấp quyền
