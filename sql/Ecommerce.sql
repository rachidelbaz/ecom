Create database ecommerce

use ecommerce
insert into tbl_admin values('rachid.elbaz@gmail.com','0522706862','1243')
update tbl_admin 
set ad_password='1234567'
select * from tbl_admin
create table tbl_admin
(
ad_id int identity primary key,
ad_email nvarchar(50) not null unique,
ad_phone nvarchar(50) not null unique,
ad_password nvarchar(50) not null,
)


create table tbl_product_category
(
cat_id int identity primary key,
cat_name nvarchar(50) not null unique,
)

create table tbl_product_items
(
pro_id int identity primary key,
pro_name nvarchar(50) not null,
pro_posted_date date,
pro_price float ,
pro_status int default 0,
pro_image nvarchar(max),
pro_qty int ,
pro_desctription ntext,
pro_fk_ad int foreign key references  tbl_admin(ad_id),
pro_fk_cat int foreign key references  tbl_product_category(cat_id)

)
Create table tbl_Client
(
Client_id int identity primary key,
Client_Name varchar(120) not null,
Client_LastName varchar(250)not null,
Client_email nvarchar(50) not null unique,
Client_password nvarchar(50) not null , 
Client_phone nvarchar(50) not null unique,
Client_Address nvarchar(max) not null
)
create Table tbl_Command
(
Command_id int identity primary key ,
Client_id int foreign key references tbl_Client (Client_id),
pro_id int foreign key references tbl_product_items(pro_id),
Qty int ,
DateC date
)

insert into tbl_product_category
values('Mobile')
insert into tbl_product_category
values('Home Appliance')
insert into tbl_product_category
values('vehicles')
insert into tbl_product_category
values('Kids')
insert into tbl_product_category
values('Services')
insert into tbl_product_category
values('Animals')
insert into tbl_product_category
values('Property')
insert into tbl_product_category
values('Fashion')

----------------------------------------------------------------------------------------------


-------------------------------------------------
create Trigger Tr_Command
on tbl_Command
instead of insert ,update
as 
begin
declare @Id_client int, @IdProduct int ,@qtyProduct int,@qtyCommand int
select @qtyCommand=Qty,@IdProduct=pro_id,@Id_client=Client_id from inserted
select @qtyProduct=pro_qty from  tbl_product_items where pro_id=@IdProduct
if(@qtyCommand<=@qtyProduct)
begin
insert into tbl_Command values(@Id_client,@IdProduct,@qtyCommand,GETDATE()) 
end
end 


--------------------------------------------------


create proc spinsert_Client
(
@Client_Name varchar(120) ,
@Client_LastName varchar(250),
@Client_email nvarchar(50),
@Client_password nvarchar(50), 
@Client_phone nvarchar(50),
@Client_Address nvarchar(max),
@id int out
)
as
begin
insert into tbl_Client
values(@Client_Name,@Client_LastName,@Client_email,@Client_password,@Client_phone,@Client_Address);

select @id=SCOPE_IDENTITY()

end

------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
Create proc sp_insert_product
(
@pro_name nvarchar(50),
@pro_posted_date date ,
@pro_price float,
@pro_image nvarchar(max),
@pro_qty int ,
@pro_desctription ntext,
@pro_fk_ad int,
@pro_fk_cat int,
@pro_id int output
)
as
begin 

insert into tbl_product_items(pro_name,pro_posted_date,pro_price,pro_status,pro_image,pro_qty,pro_desctription,pro_fk_ad,pro_fk_cat)
values(
@pro_name ,
@pro_posted_date ,
@pro_price ,1,
@pro_image ,
@pro_qty,
@pro_desctription,
@pro_fk_ad ,
@pro_fk_cat

)
select @pro_id =SCOPE_IDENTITY()
end


  -----------------------------------------------------------

CREATE PROCEDURE GetproductsPageWise
      @pro_fk_cat int,
      @PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY pro_id desc
      )AS RowNumber

     
      ,pro_name,

      pro_price,
	  pro_image,
	  pro_id
	 
	 
	  
     INTO #Results
      FROM tbl_product_items
	  where pro_fk_cat=@pro_fk_cat and pro_status=1
     
      SELECT @RecordCount = COUNT(*)
      FROM #Results
           
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
     
      DROP TABLE #Results
END
GO
---------------------------------------------------------------------------------------------
Create PROCEDURE GetSearchproductsPageWise
     @pro_name nvarchar(50),
      @PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY pro_id desc
      )AS RowNumber

     
      ,pro_name,

      pro_price,
	  pro_image,
	  pro_id
	 
	 
	  
     INTO #Results
      FROM tbl_product_items
	  where pro_name like '%'+@pro_name+'%' and pro_status=1
     
      SELECT @RecordCount = COUNT(*)
      FROM #Results
           
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
     
      DROP TABLE #Results
END
GO
----------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
Create PROCEDURE GetproductsPageWise1
      @PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY pro_id ASC
      )AS RowNumber
      ,pro_id
      ,pro_name
      ,pro_price
	  ,pro_image
     INTO #Results
      FROM tbl_product_items
     
      SELECT @RecordCount = COUNT(*)
      FROM #Results
           
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
     
      DROP TABLE #Results
END
GO
-----------------------------------------------------------------------------------------------------------------------
Create proc spGetProducts
@StartIndex int,
@MaximumRows int
as
Begin
 Set @StartIndex = @StartIndex + 1
 
 Select pro_id, pro_name, pro_price, pro_image from
 (Select ROW_NUMBER() over (order by pro_id) as RowNumber, pro_id, pro_name, pro_price, pro_image
  from tbl_product_items) Products
 Where RowNumber >= @StartIndex and RowNumber < (@StartIndex + @MaximumRows)
End
------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
USE [ecommerce]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[sp_insert_product]
(
@pro_name nvarchar(50),
@pro_posted_date date ,
@pro_price float,
@pro_image nvarchar(max),
@pro_fk_ad int,
@pro_fk_cat int,
@pro_id int out
)
as
begin 

insert into tbl_product_items(pro_name,pro_posted_date,pro_price,pro_status,pro_image,pro_fk_ad,pro_fk_cat)
values(
@pro_name ,
@pro_posted_date ,
@pro_price ,1,
@pro_image ,
@pro_fk_ad ,
@pro_fk_cat

)

select  @pro_id=SCOPE_IDENTITY()

end


 -- ===================================================================================================================================
 select * from tbl_product_items
update tbl_product_items set pro_qty=13,pro_desctription='fdfhgfhsfshf', pro_fk_cat=3, pro_price=3400 , pro_name='Iphone' where pro_id=19
select pro_id,pro_name,pro_image,pro_qty,pro_desctription,pro_price,cat_name from tbl_product_items P inner join tbl_product_category C on P.pro_fk_cat=C.cat_id where pro_fk_ad=1



select ad_email from tbl_admin where ad_id=1


select * from sys.tables

select * from tbl_product_category
select * from tbl_product_items
select * from tbl_Client where Client_id=

update tbl_Client set Client_Name='' ,Client_LastName='',Client_email='',Client_password='',Client_phone='',Client_Address='' where Client_id=

select count(*) from tbl_Client where Client_email='khalid@gmail.com' and Client_id !=2 

select * from tbl_product_items i inner join tbl_product_category c on c.cat_id=i.pro_fk_cat
select count(Client_id) from tbl_Client where Client_email=


select * from tbl_admin where ad_email
select * from tbl_product_category

select top 4 p.pro_id,pro_name,pro_price,pro_image from tbl_product_items p inner join Command C on P.pro_id=C.pro_id order by qty desc


select Cl.Client_Name,Cl.Client_LastName,Cl.Client_Address,Cl.Client_phone,P.pro_name,P.pro_image,P.pro_price,C.Qty from tbl_Client Cl inner join tbl_Command C on Cl.Client_id=C.Client_id inner join tbl_product_items P on C.pro_id=P.pro_id where P.pro_fk_ad='1' and Day(C.DateC)=Day(GETDATE()) and YEAR(C.DateC)=YEAR(GETDATE()) Group by  Cl.Client_Name,Cl.Client_LastName,Cl.Client_Address,Cl.Client_phone,P.pro_name,P.pro_image,P.pro_price,C.Qty;
select * from tbl_product_items
select * from tbl_Client



update tbl_product_items set pro_qty-=1 where pro_id=13
select count(ad_id) from tbl_admin  where ad_email='rachiddelbaz@gmail.com'
select count(Client_id) from tbl_Client  where Client_email='rachiddelbaz@gmail.com'
select * from tbl_product_items

select p.pro_id,p.pro_name,p.pro_posted_date,p.pro_price,p.pro_image,a.ad_email,a.ad_phone from tbl_product_items p inner join tbl_admin a on a.ad_id=p.pro_fk_ad where p.pro_id=3
select pro_id,pro_name,pro_price,pro_image from tbl_product_items where pro_id=4


