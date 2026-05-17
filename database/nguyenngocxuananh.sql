﻿--Câu 3: b.Truy vấn: Truy vấn với Aggregate Functions (7 câu), e. Truy vấn không/chưa có (NOT IN/ LEFT JOIN -RIGHT JOIN) (5 câu)
--Câu 4: Tạo 2 thủ tục, 2 hàm, 1 trigger
--Câu 5: Tạo 1 người dùng và cấp quyền 
USE QLNT;

--Câu 3b:
--1/ Tính tuổi trung bình của các tù nhân đang thi hành án - AVG 
SELECT AVG(DATEDIFF(YEAR, TN.NgaySinh, GETDATE())) AS TuoiTrungBinhToanTrai
FROM TUNHAN TN
WHERE TN.TrangThai = N'Đang thi hành án';

--2/ Tìm tù nhân có mức án tù lớn nhất - MAX
SELECT TN.MaTuNhan, TN.HoTen, BA.ToiDanh, BA.MucAn
FROM BANAN BA
JOIN TUNHAN TN ON TN.MaTuNhan = BA.MaTuNhan
WHERE DATEDIFF(YEAR, BA.NgayBatDauThiHanhAn, BA.NgayKetThucDuKien) = 
      (SELECT MAX(DATEDIFF(YEAR, NgayBatDauThiHanhAn, NgayKetThucDuKien)) FROM BANAN);

--3/ Đếm số tội danh xuất hiện nhiều nhất -> tội phổ biến nhất - COUNT
SELECT TD.TenToiDanh, COUNT(BATD.MaBanAn) AS TongSoLanXuatHien
FROM TOIDANH TD
LEFT JOIN BANAN_TOIDANH BATD ON TD.MaToiDanh = BATD.MaToiDanh
GROUP BY TD.TenToiDanh
ORDER BY TongSoLanXuatHien DESC;

--4/ Tìm quản ngục có số lương thấp nhất - MIN 
SELECT QN.MaQuanNguc, QN.TenQuanNguc, QN.ChucVu, QN.Luong
FROM QUANNGUC QN
WHERE QN.Luong = (SELECT MIN(Luong) FROM QUANNGUC);

--5/ Tính tổng sức chứa tối đa của các phòng giam từng khu vực
SELECT PG.MaKV, SUM(PG.SucChua) AS TongSucChuaToiDa
FROM PHONGGIAM PG
GROUP BY PG.MaKV;

--6/ Đếm số lịch thăm nuôi theo trạng thái (Đã duyệt, Chưa duyệt, Không duyệt)
SELECT TrangThai, COUNT(*) AS SoLuongLich
FROM LICHTHAMNUOI
GROUP BY TrangThai
ORDER BY SoLuongLich DESC;

--7/ Tính số công việc trung bình mỗi tù nhân đã tham gia
SELECT AVG(SoCongViec * 1.0) AS SoCongViecTrungBinh
FROM (
    SELECT MaTuNhan, COUNT(MaCongViec) AS SoCongViec
    FROM CAITAO
    GROUP BY MaTuNhan
) AS BangTam;

-- Câu 3e:
--1/ Liệt kê danh sách các quản ngục (Mã, Tên, Chức vụ) không thuộc các khu vực quản lý là 'KVA' và 'KVB'.
SELECT MaQuanNguc, TenQuanNguc, ChucVu 
FROM QUANNGUC 
WHERE MaKV NOT IN ('KVA', 'KVB');

--2/ Liệt kê danh sách những phòng giam không trống -> đang được sử dụng 
SELECT PG.MaPhong, PG.MaKV, PG.SucChua, PG.TrangThai, PG.LoaiPhong, PG.SoLuongHienTai, PG.GhiChu FROM PHONGGIAM PG
LEFT JOIN TUNHAN TN ON TN.MaPhong = PG.MaPhong
WHERE TN.MaTuNhan IS NOT NULL;

--3/ Liệt kê những quản ngục (Mã, Tên, Chức vụ) không quản lý phòng giam nào 
SELECT QN.MaQuanNguc, QN.TenQuanNguc, QN.ChucVu
FROM PHONGGIAM PG
RIGHT JOIN QUANNGUC QN ON PG.MaQuanNguc = QN.MaQuanNguc
WHERE PG.MaPhong IS NULL;

--4/ Tìm tù nhân chưa từng được người thân đến thăm
SELECT TN.MaTuNhan, TN.HoTen, TN.MucDoNguyHiem 
FROM TUNHAN TN
LEFT JOIN THANNHAN TNH ON  TNH.MaTuNhan = TN.MaTuNhan
WHERE TN.MaPhong IS NOT NULL AND TNH.MaTuNhan IS NULL;

--5/ Tìm danh sách những tù nhân có đánh giá tốt 
SELECT TN.MaTuNhan, TN.HoTen
WHERE TN.MaTuNhan NOT IN (
	SELECT CT.MaTuNhan
    FROM CAITAO CT 
    WHERE CT.DanhGia = N'Kém' AND CT.DanhGia = N'Trung bình' AND CT.DanhGia = N'Khá'
);

--Câu 4: Stored Procedure - Tìm danh sách tù nhân theo giới tính 
CREATE PROC sp_gioitinh_select @GioiTinh nvarchar(5)
AS BEGIN 
	SELECT MaTuNhan, SoCCCD, HoTen, GioiTinh
	FROM TUNHAN
	WHERE GioiTinh = @GioiTinh 
END;

sp_gioitinh_select Nữ;
sp_gioitinh_select Nam;

--Câu 4: Stored Procedure - Tìm thông tin tù nhân ở tù sớm nhất 
CREATE PROC sp_tunhan_select 
AS BEGIN 
	DECLARE @max int;
	SELECT @max = MAX(DATEDIFF(YEAR, NgayBatDauThiHanhAn, GETDATE()))
	FROM BANAN 
	WHERE NgayBatDauThiHanhAn IS NOT NULL;
	SELECT TN.MaTuNhan, SoCCCD, HoTen, NgaySinh, GioiTinh, BA.NgayBatDauThiHanhAn
	FROM TUNHAN TN
	JOIN BANAN BA ON BA.MaTuNhan = TN.MaTuNhan
	WHERE DATEDIFF(YEAR, NgayBatDauThiHanhAn, GETDATE()) = @max 
END;

sp_tunhan_select;

--Câu 4: Function - Cho biết số lượng phòng giam theo mã khu vực 
CREATE FUNCTION fn_soluong_select (@MaKV varchar(10)) 
RETURNS int
AS BEGIN
    DECLARE @SoLuong int;
    SELECT @SoLuong = COUNT(MaPhong)  
	FROM PHONGGIAM 
	WHERE MaKV  = @MaKV;
    RETURN @SoLuong;
END;

SELECT N'Số phòng giam khu A là:' AS ThongBao, dbo.fn_soluong_select ('KVA') AS SoLuong;
SELECT N'Số phòng giam khu B là:' AS ThongBao, dbo.fn_soluong_select ('KVB') AS SoLuong;
SELECT N'Số phòng giam khu C là:' AS ThongBao, dbo.fn_soluong_select ('KVC') AS SoLuong;
SELECT N'Số phòng giam khu D là:' AS ThongBao, dbo.fn_soluong_select ('KVD') AS SoLuong;

--Câu 4: Function - Tìm những quản ngục có mức lương cao hơn mức lương cần tìm
CREATE FUNCTION fn_quannguc_select (@Luong decimal(10,2)) RETURNS 
@RETURNTABLE TABLE 
	(
		MaQuanNguc varchar(10),
		TenQuanNguc nvarchar(100),
		Luong decimal(10,2)
	)
AS BEGIN
    INSERT INTO @RETURNTABLE
    SELECT MaQuanNguc, TenQuanNguc, Luong
    FROM QUANNGUC
    WHERE Luong > @Luong 
    RETURN
END;

SELECT * FROM dbo.fn_quannguc_select (13000000) ORDER BY Luong ASC;

--Câu 4: Trigger - Khi thêm vào bảng CONGVIEC: SoLuongToiDa phải >=4 và <=15
IF EXISTS (SELECT name FROM sysobjects 
           WHERE name = 'tr_congviec_insert' AND type = 'tr')
    DROP TRIGGER tr_congviec_insert
GO
	CREATE TRIGGER tr_congviec_insert 
ON CONGVIEC
FOR INSERT
AS BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE SoLuongToiDa NOT BETWEEN 4 AND 15
    )
    BEGIN
        RAISERROR (N'Số lượng tối đa phải >= 4 và <= 15', 16, 1)
        ROLLBACK
        RETURN
    END
END;

INSERT INTO [CONGVIEC] ([MaCongViec], [TenCongViec], [SoLuongToiDa], [MoTa], [MucDoNguyHiem], [MaQuanNguc], [TrangThai])
VALUES
('CV009', N'Giặc và cấp phát đồ dùng', 8,N'Giặc và sấy đồ, sau khi xong cấp phát đến tủ đồ các phòng giam',N'Thấp', 'QN05', N'Đang hoạt động');

SELECT * FROM CONGVIEC;

--Câu 5: Tạo 1 người dùng và cấp quyền
CREATE LOGIN thannhan_qlnt WITH PASSWORD = 'Thannhan@123';
USE QLNT;
CREATE USER thannhan_user FOR LOGIN thannhan_qlnt;
GRANT SELECT ON LICHTHAMNUOI TO thannhan_user;
GRANT SELECT ON THANNHAN TO thannhan_user;

