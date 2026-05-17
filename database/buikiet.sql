USE QLNT;
-- CÂU 3A: TRUY VẤN ĐƠN GIẢN (5 câu)

-- 3a.1: Hiển thị danh sách tất cả tù nhân đang thi hành án
SELECT MaTuNhan, HoTen, NgaySinh, GioiTinh, MaPhong, MucDoNguyHiem
FROM TUNHAN
WHERE TrangThai = N'Đang thi hành án';

-- 3a.2: Hiển thị danh sách quản ngục thuộc khu vực KVA
SELECT MaQuanNguc, TenQuanNguc, GioiTinh, ChucVu, Luong
FROM QUANNGUC
WHERE MaKV = 'KVA'
ORDER BY Luong DESC;

-- 3a.3: Hiển thị danh sách phòng giam đang trống
SELECT MaPhong, MaKV, SucChua, LoaiPhong, GhiChu
FROM PHONGGIAM
WHERE TrangThai = N'Trống';

-- 3a.4: Hiển thị thông tin tù nhân có mức độ nguy hiểm 'Rất cao'
SELECT MaTuNhan, HoTen, NgaySinh, DiaChi, MaPhong, GhiChu
FROM TUNHAN
WHERE MucDoNguyHiem = N'Rất cao';

-- 3a.5: Hiển thị danh sách vi phạm kỷ luật xảy ra trong năm 2025
SELECT MaViPham, MaTuNhan, NgayViPham, NoiDung, HinhThucXuLy
FROM VIPHAMKYLUAT
WHERE YEAR(NgayViPham) = 2025
ORDER BY NgayViPham;

-- CÂU 3G: TRUY VẤN UPDATE, DELETE (7 câu)

-- 3g.1: Cập nhật lương cho quản ngục QN01 tăng thêm 10%
UPDATE QUANNGUC
SET Luong = Luong * 1.10
WHERE MaQuanNguc = 'QN01';

-- Kiểm tra kết quả
SELECT MaQuanNguc, TenQuanNguc, Luong FROM QUANNGUC WHERE MaQuanNguc = 'QN01';

-- 3g.2: Cập nhật trạng thái phòng giam PA103 thành 'Đang sử dụng'
UPDATE PHONGGIAM
SET TrangThai = N'Đang sử dụng'
WHERE MaPhong = 'PA103';

-- Kiểm tra kết quả
SELECT MaPhong, TrangThai FROM PHONGGIAM WHERE MaPhong = 'PA103';

-- 3g.3: Cập nhật trạng thái tù nhân TN003 thành 'Đã mãn hạn' (đã có ngày xuất trại)
UPDATE TUNHAN
SET TrangThai = N'Đã mãn hạn', MaPhong = NULL
WHERE MaTuNhan = 'TN003' AND NgayXuatTrai IS NOT NULL;

-- Kiểm tra kết quả
SELECT MaTuNhan, HoTen, TrangThai, MaPhong FROM TUNHAN WHERE MaTuNhan = 'TN003';

-- 3g.4: Cập nhật hình thức xử lý vi phạm VP001 từ 'Cảnh cáo' thành 'Lao động công ích'
UPDATE VIPHAMKYLUAT
SET HinhThucXuLy = N'Lao động công ích',
    GhiChu = N'Nâng mức xử lý do tái phạm'
WHERE MaViPham = 'VP001';

-- Kiểm tra kết quả
SELECT * FROM VIPHAMKYLUAT WHERE MaViPham = 'VP001';

-- 3g.5: Cập nhật trạng thái tài khoản của quản ngục QN16 thành 'Hoạt động'
UPDATE TAIKHOAN
SET TrangThai = N'Hoạt động'
WHERE MaQuanNguc = 'QN16';

-- Kiểm tra kết quả
SELECT MaTaiKhoan, TenDangNhap, TrangThai FROM TAIKHOAN WHERE MaQuanNguc = 'QN16';

-- 3g.6: Xóa lịch thăm nuôi chưa được duyệt của tù nhân TN001
DELETE FROM LICHTHAMNUOI
WHERE MaTuNhan = 'TN001'
  AND TrangThai = N'Chưa duyệt';

-- Kiểm tra kết quả
SELECT * FROM LICHTHAMNUOI WHERE MaTuNhan = 'TN001';

-- 3g.7: Xóa lịch thăm nuôi bị từ chối (Không duyệt) của tù nhân TN007
DELETE FROM LICHTHAMNUOI
WHERE MaTuNhan = 'TN007'
  AND TrangThai = N'Không duyệt';

-- Kiểm tra kết quả
SELECT * FROM LICHTHAMNUOI WHERE MaTuNhan = 'TN007';

-- CÂU 4: THỦ TỤC, HÀM, TRIGGER

-- THỦ TỤC 1: Tìm kiếm tù nhân theo tên (có hỗ trợ tìm gần đúng)
GO
CREATE PROCEDURE sp_TimKiemTuNhan
    @HoTen NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        TN.MaTuNhan,
        TN.HoTen,
        TN.NgaySinh,
        TN.GioiTinh,
        TN.MaPhong,
        TN.TrangThai,
        TN.MucDoNguyHiem
    FROM TUNHAN TN
    WHERE TN.HoTen LIKE N'%' + @HoTen + N'%'
    ORDER BY TN.HoTen;
END;
GO

-- Ví dụ minh họa:
-- EXEC sp_TimKiemTuNhan N'Nguyễn';

-- THỦ TỤC 2: Thêm vi phạm kỷ luật mới cho tù nhân

GO
CREATE PROCEDURE sp_ThemViPham
    @MaViPham   VARCHAR(10),
    @MaTuNhan   VARCHAR(10),
    @NgayViPham DATE,
    @NoiDung    NVARCHAR(100),
    @HinhThucXuLy NVARCHAR(50),
    @GhiChu     NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tù nhân có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM TUNHAN WHERE MaTuNhan = @MaTuNhan)
    BEGIN
        RAISERROR(N'Tù nhân không tồn tại trong hệ thống!', 16, 1);
        RETURN;
    END

    INSERT INTO VIPHAMKYLUAT (MaViPham, MaTuNhan, NgayViPham, NoiDung, HinhThucXuLy, GhiChu)
    VALUES (@MaViPham, @MaTuNhan, @NgayViPham, @NoiDung, @HinhThucXuLy, @GhiChu);

    PRINT N'Đã thêm vi phạm kỷ luật thành công!';
END;
GO

-- Ví dụ minh họa:
-- EXEC sp_ThemViPham 'VP021', 'TN010', '2026-05-01', N'Gây rối trong giờ nghỉ', N'Cảnh cáo', N'Vi phạm lần đầu';


-- HÀM 1 (Scalar): Đếm số lần vi phạm kỷ luật của một tù nhân
GO
CREATE FUNCTION fn_DemViPham (@MaTuNhan VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @SoLanViPham INT;
    SELECT @SoLanViPham = COUNT(*)
    FROM VIPHAMKYLUAT
    WHERE MaTuNhan = @MaTuNhan;
    RETURN @SoLanViPham;
END;
GO

-- Ví dụ minh họa:
-- SELECT dbo.fn_DemViPham('TN004') AS SoLanViPham;
-- SELECT MaTuNhan, HoTen, dbo.fn_DemViPham(MaTuNhan) AS SoLanViPham FROM TUNHAN;

-- HÀM 2 (Table-valued): Lấy danh sách tù nhân trong một phòng giam
GO
CREATE FUNCTION fn_DanhSachTuNhanTheoPhong (@MaPhong VARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        TN.MaTuNhan,
        TN.HoTen,
        TN.NgaySinh,
        TN.GioiTinh,
        TN.TrangThai,
        TN.MucDoNguyHiem
    FROM TUNHAN TN
    WHERE TN.MaPhong = @MaPhong
);
GO

-- Ví dụ minh họa:
-- SELECT * FROM dbo.fn_DanhSachTuNhanTheoPhong('PC101');

-- TRIGGER: Tự động cập nhật TrangThai phòng giam khi tù nhân được chuyển phòng
-- (Khi UPDATE MaPhong trong TUNHAN → cập nhật TrangThai phòng cũ và mới)
GO
CREATE TRIGGER trg_CapNhatPhongGiam
ON TUNHAN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ xử lý khi cột MaPhong bị thay đổi
    IF UPDATE(MaPhong)
    BEGIN
        DECLARE @MaPhongCu  VARCHAR(10);
        DECLARE @MaPhongMoi VARCHAR(10);

        SELECT @MaPhongCu  = d.MaPhong FROM deleted d;
        SELECT @MaPhongMoi = i.MaPhong FROM inserted i;

        -- Nếu phòng cũ không còn tù nhân nào → đổi trạng thái thành 'Trống'
        IF @MaPhongCu IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM TUNHAN
                WHERE MaPhong = @MaPhongCu
                  AND TrangThai NOT IN (N'Đã mãn hạn', N'Đang theo dõi')
            )
            BEGIN
                UPDATE PHONGGIAM
                SET TrangThai = N'Trống'
                WHERE MaPhong = @MaPhongCu;
            END
        END

        -- Nếu phòng mới có tù nhân → đổi trạng thái thành 'Đang sử dụng'
        IF @MaPhongMoi IS NOT NULL
        BEGIN
            UPDATE PHONGGIAM
            SET TrangThai = N'Đang sử dụng'
            WHERE MaPhong = @MaPhongMoi
              AND TrangThai = N'Trống';
        END
    END
END;
GO

-- CÂU 5: TẠO 5 NGƯỜI DÙNG VÀ CẤP QUYỀN

-- Lưu ý: Chạy từng lệnh CREATE LOGIN / USER trên SQL Server Management Studio
-- với quyền sysadmin hoặc securityadmin

-- USER 1: admin_qlnt - Quản trị viên hệ thống (toàn quyền trên QLNT)
CREATE LOGIN admin_qlnt WITH PASSWORD = 'Admin@2026!';
GO
USE QLNT;
GO
CREATE USER admin_qlnt FOR LOGIN admin_qlnt;
GO
-- Cấp toàn quyền trên database QLNT
GRANT CONTROL ON DATABASE::QLNT TO admin_qlnt;
GO

-- USER 2: truong_khu - Trưởng khu (đọc + cập nhật tù nhân, phòng giam)
CREATE LOGIN truong_khu WITH PASSWORD = 'Truong@2026!';
GO
USE QLNT;
GO
CREATE USER truong_khu FOR LOGIN truong_khu;
GO
GRANT SELECT, INSERT, UPDATE ON TUNHAN       TO truong_khu;
GRANT SELECT, UPDATE          ON PHONGGIAM   TO truong_khu;
GRANT SELECT                  ON KHUVUC      TO truong_khu;
GRANT SELECT                  ON QUANNGUC    TO truong_khu;
GRANT SELECT, INSERT          ON VIPHAMKYLUAT TO truong_khu;
GRANT SELECT, INSERT          ON LICHSUCHUYENPHONG TO truong_khu;
GO

-- USER 3: quan_nguc - Quản ngục (chỉ xem và quản lý thăm nuôi, cải tạo)
CREATE LOGIN quan_nguc WITH PASSWORD = 'QuanNguc@2026!';
GO
USE QLNT;
GO
CREATE USER quan_nguc FOR LOGIN quan_nguc;
GO
GRANT SELECT         ON TUNHAN        TO quan_nguc;
GRANT SELECT         ON PHONGGIAM     TO quan_nguc;
GRANT SELECT, INSERT, UPDATE ON THAMNUOI      TO quan_nguc;
GRANT SELECT, INSERT, UPDATE ON LICHTHAMNUOI  TO quan_nguc;
GRANT SELECT, INSERT, UPDATE ON CAITAO        TO quan_nguc;
GRANT SELECT         ON CONGVIEC      TO quan_nguc;
-- Từ chối quyền xóa dữ liệu
DENY DELETE ON TUNHAN       TO quan_nguc;
DENY DELETE ON THAMNUOI     TO quan_nguc;
GO

-- USER 4: than_nhan_vien - Nhân viên tra cứu thân nhân (chỉ đọc)
CREATE LOGIN than_nhan_vien WITH PASSWORD = 'ThanNhan@2026!';
GO
USE QLNT;
GO
CREATE USER than_nhan_vien FOR LOGIN than_nhan_vien;
GO
GRANT SELECT ON THANNHAN      TO than_nhan_vien;
GRANT SELECT ON LICHTHAMNUOI  TO than_nhan_vien;
GRANT SELECT ON TUNHAN        TO than_nhan_vien;
-- Từ chối sửa và xóa
DENY INSERT, UPDATE, DELETE ON THANNHAN     TO than_nhan_vien;
DENY INSERT, UPDATE, DELETE ON LICHTHAMNUOI TO than_nhan_vien;
GO

-- USER 5: bao_ve - Nhân viên bảo vệ (chỉ xem phòng giam và tù nhân, không được sửa)
CREATE LOGIN bao_ve WITH PASSWORD = 'BaoVe@2026!';
GO
USE QLNT;
GO
CREATE USER bao_ve FOR LOGIN bao_ve;
GO
GRANT SELECT ON TUNHAN    TO bao_ve;
GRANT SELECT ON PHONGGIAM TO bao_ve;
GRANT SELECT ON KHUVUC    TO bao_ve;
-- Từ chối mọi quyền thay đổi dữ liệu
DENY INSERT, UPDATE, DELETE ON TUNHAN    TO bao_ve;
DENY INSERT, UPDATE, DELETE ON PHONGGIAM TO bao_ve;
GO

-- Kiểm tra danh sách người dùng trong database QLNT
SELECT name, type_desc, create_date
FROM sys.database_principals
WHERE type IN ('S', 'U')
  AND name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys');
GO
