--3.d.	Truy vấn lớn nhất, nhỏ nhất: 4 câu (4 đ) (Vũ)
--3.f.	Truy vấn Hợp/Giao/Trừ: 3 câu (3đ) (Vũ)
--4.	Tạo 7 thủ tục, 8 hàm và 5 trigger. Lưu ý thủ tục và hàm có cho ví dụ minh họa. (25 đ) 2 2 2 1


---===============================================-
--3.d.	Truy vấn lớn nhất, nhỏ nhất: 4 câu (4 đ) (Vũ)
--1. Tìm thông tin Tù nhân lớn tuổi nhất trong nhà tù
SELECT TOP 1 *
FROM TUNHAN
ORDER BY NgaySinh ASC;

--2. Tìm quản ngục có lương cao nhất 
SELECT *
FROM QUANNGUC
WHERE Luong = (
    SELECT MAX(Luong)
    FROM QUANNGUC
);

--3. Cho biết công việc có số lượng tối đa nhỏ nhất và quản ngục phụ trách
SELECT TOP 1 CV.MaCongViec, CV.TenCongViec, CV.SoLuongToiDa, QN.TenQuanNguc
FROM CONGVIEC CV
JOIN QUANNGUC QN ON CV.MaQuanNguc = QN.MaQuanNguc
ORDER BY CV.SoLuongToiDa ASC;


--4. Tìm quản ngục có mức lương cao nhất đang phụ trách cải tạo tù nhân
SELECT QN.MaQuanNguc, QN.TenQuanNguc, QN.Luong, TN.HoTen
FROM QUANNGUC QN
JOIN CAITAO CT ON QN.MaQuanNguc = CT.MaQuanNgucPhuTrach
JOIN TUNHAN TN ON CT.MaTuNhan = TN.MaTuNhan
WHERE QN.Luong = (
    SELECT MAX(Luong)
    FROM QUANNGUC
);

--3.f.	Truy vấn Hợp/Giao/Trừ: 3 câu (3đ) (Vũ)
  
--1. Gộp danh sách quản ngục và tù nhân thành một danh sách chung.
SELECT QN.TenQuanNguc AS Ten, QN.DiaChi, N'Quản ngục' AS Loai
FROM QUANNGUC QN

UNION

SELECT TN.HoTen, TN.DiaChi, N'Tù nhân' AS Loai
FROM TUNHAN TN
-- 2. Tìm những tù nhân vừa bị vi phạm kỷ luật, vừa có kết quả cải tạo tốt.
SELECT TN.MaTuNhan, TN.HoTen
FROM TUNHAN TN
JOIN VIPHAMKYLUAT VP ON TN.MaTuNhan = VP.MaTuNhan

INTERSECT

SELECT TN.MaTuNhan, TN.HoTen
FROM TUNHAN TN
JOIN CAITAO CT ON TN.MaTuNhan = CT.MaTuNhan
WHERE CT.DanhGia = N'Tốt'

--3. Cho biết các phòng giam chưa có tù nhân nào đang ở
SELECT PG.MaPhong, QN.TenQuanNguc, PG.SucChua
FROM PHONGGIAM PG
JOIN QUANNGUC QN ON PG.MaQuanNguc = QN.MaQuanNguc

EXCEPT

SELECT PG.MaPhong, QN.TenQuanNguc, PG.SucChua
FROM PHONGGIAM PG
JOIN QUANNGUC QN ON PG.MaQuanNguc = QN.MaQuanNguc
JOIN TUNHAN TN ON PG.MaPhong = TN.MaPhong;














--4.	Tạo 7 thủ tục, 8 hàm và 5 trigger. Lưu ý thủ tục và hàm có cho ví dụ minh họa. (25 đ) 2 2 2 1
