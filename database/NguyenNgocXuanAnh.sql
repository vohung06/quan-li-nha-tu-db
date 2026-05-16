--Cau 4: Tìm danh sách tù nhân theo giới tính 
CREATE PROC sp_gioitinh_select @GioiTinh NVARCHAR(5)
AS BEGIN 
SELECT MaTuNhan, SoCCCD, HoTen, GioiTinh
FROM TUNHAN
WHERE GioiTinh = @GioiTinh END;

sp_gioitinh_select Nữ;
sp_gioitinh_select Nam;