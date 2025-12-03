use cafe
select * from cafe
-- Quantity,Price_Per_unit,Total_spent sutunlarindan Null deyerlerin silinmesi

update cafe 
set Total_Spent=Quantity*Price_Per_Unit 
where quantity is not null or Price_Per_Unit is not null

delete from cafe
where Quantity is null or Price_Per_Unit is null or total_spent is null

select * from cafe
-- Payment_Metod-da Null deyerlerin  unknown olaraq deyisdirilmesi
select * from cafe

select  Payment_Method from cafe 
where Payment_Method is null

update cafe 
set Payment_Method='unknown'
where Payment_Method in ('error','unknown') or Payment_Method is null

-- Transaction_Date sutunlarindan Null deyerlerin silinmesi

delete from cafe 
where Transaction_Date is null

--Tarix formatinin mm/dd/yyyy-dan dd/mm/yyyy-a cevrilmesi
update cafe 
set 
Transaction_Date=convert(date,Transaction_Date,111)

select format(Transaction_Date,'dd/MM/yyyy') 
as Formatlanmis_Date 
from Cafe

--Item sutununda null deyerlerin duzeldilmesi
select * from cafe 

select distinct item from cafe

SELECT 
    distinct item, Price_Per_Unit,Total_Spent
FROM cafe
UPDATE cafe
SET item = (
    SELECT TOP 1 c2.item
    FROM cafe AS c2
    WHERE c2.item IS NOT NULL
      AND c2.item NOT IN ('error', 'unknown')
      AND ROUND(c2.total_spent / NULLIF(c2.quantity, 0), 2) = ROUND(cafe.total_spent / NULLIF(cafe.quantity, 0), 2)
)
WHERE item IS NULL 
   OR item IN ('error', 'unknown');

   --Location hissesindeki deyerlerin duzgun veziyyete getirilmesi
   update cafe 
   set location='unknown' 
   where Location in ('unknown','error', 'null')  or Location is null

   -- case when emeliyyati
   select * from cafe
   select TRANSACTION_ID,Item,
    case 
   when total_spent>=10  then 'High'
   when Total_Spent<10 then 'Low'
   end as Qiymet_Yuksekliyi
   from cafe 
    order by Quantity

--en cox total_Spente malik item-ler

  select top 5  total_spent ,item,Transaction_id from cafe 
  order by total_spent desc

--view yaratmaq
create view Cafe1 (ID,Mehsul) as 
select Transaction_ID,Item 
from cafe
select * from Cafe1

--where istifade olunan view

 create view Where_view 
 as
 select * from cafe
 where  Price_Per_Unit<3
 or
 Total_Spent>7.5

  select * from Where_view

  --Her Item-a uygun toplam satis ve sayi gosteren view

create view View2(Item,Toplam_cem,Say)
as 
select item,sum(total_spent),Count(item) from cafe
group by item

select * from View2
Drop view Zaman_View

--Zaman esasli view 

create view Zaman_view
as
select year(Transaction_date) as Il,
       month(Transaction_date) as ay,
	 count( ID) as Tranzaksiya
	  from cafe
	  group by year(Transaction_date), month(Transaction_date)
	  drop view Zaman_view

select * from Zaman_View

--Price ve Total_spent-in yenilenmesi

create trigger UpdatePQT
on cafe
after update
as 
begin
select * from cafe union all
  select 'Update edildi'
  end;
   begin transaction
  update  c
  set c.Price_Per_Unit=c.Price_Per_Unit+0.5 , c.Total_Spent=c.Quantity* c.Price_Per_Unit  
  from cafe c
  where item in('Sandwhich','salad','tea')
   rollback
 
--İnsert  emeliyyati üçün trigger

  
  CREATE TRIGGER Insert_Show_NewData
ON Cafe
AFTER INSERT
AS
BEGIN
    PRINT 'Yeni melumatlar elave olundu:';
    SELECT * FROM inserted;  -- bu, ancaq indi daxil edilən sətirlərdir
END;

--Diger Trigger
ALTER TABLE Cafe
ADD ID  INT IDENTITY(1,1);
ALTER TABLE Cafe
add CONSTRAINT PK_Cafe Primary key(ID);

ALTER TABLE Cafe
DROP CONSTRAINT PK_Cafe;
ALTER TABLE Cafe
drop column  New_Transaction_ID ;
select * from cafe


CREATE TRIGGER Cafe_Insert_AutoFill
ON Cafe
AFTER INSERT
AS
BEGIN
    -- Yeni daxil edilən sətirləri avtomatik tamamlayır
    UPDATE c
    SET 
        c.Total_Spent = c.Quantity * c.Price_Per_Unit,  -- məbləği hesablayır
        c.Transaction_Date = GETDATE()                   -- sistem tarixi əlavə edir
    FROM Cafe c
    ;

    PRINT 'Yeni tranzaksiya elave olundu — Total_Spent və Transaction_Date avtomatik yazıldı.';
END;

insert into Cafe(item,quantity,Price_Per_Unit,Payment_Method,Location) 
values ('Juice',4,4,'Credit Card','Takeaway')

CREATE TRIGGER Cafe_Update
ON Cafe
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Quantity) OR UPDATE(Price_Per_Unit)
    BEGIN
        UPDATE c
        SET c.Total_Spent = c.Quantity * c.Price_Per_Unit
        FROM Cafe c

        PRINT 'Tranzaksiya yeniləndi, Total_Spent avtomatik yeniləndi.';
    END
END;
 update cafe 
 set Price_Per_Unit=Price_Per_Unit-1
 where  Quantity>3 and Price_Per_Unit>3

 select * from cafe

 --Index yaratmaq

  create index Cafe_I
  on Cafe(Id, Item)

  --Funksiya yaratmaq 

 CREATE FUNCTION dbo.araliq(@total_spent FLOAT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @result VARCHAR(20);

    IF @total_spent < 5
        SET @result = 'Aşağı satış';
    ELSE IF @total_spent >= 5 AND @total_spent <= 10
        SET @result = 'Orta satış';
    ELSE -- 10-dan böyük bütün hallarda
        SET @result = 'Yüksək satış';

    RETURN @result;
END;


drop function araliq
SELECT 
    Item,
    Total_Spent,
    dbo.araliq(c.total_spent) AS Satis_Seviyesi
FROM Cafe c;

--
create function Komissiya(@Metod nvarchar(50),@Total float)
returns decimal(10,2)
as  
begin
declare @komissiya decimal(10,2);
if @Metod='Credit Card'
   set @komissiya=@Total * 0.02;
else 
   set  @komissiya=0;
return @komissiya
end;
        
		drop function komissiya

select item,quantity,dbo.Komissiya(c.Payment_Method,c.Total_Spent) as komissiya from cafe c
 select * from cafe

 --Total_spent-i 10-dan çox olan deyerleri getiren prosedur

 create procedure TotalSpent10
 as
 begin
  select * from cafe where Total_Spent>10
  end;
   exec TotalSpent10

   --Secilmis mehsulun qiymetini deyisen prosedur

   create procedure Qiymet
   @Dəyər int,@Məhsul varchar(50)
   as begin 
   update Cafe
   set Price_Per_Unit=@Dəyər
   where Item=@Məhsul
   update Cafe
   set Total_Spent=Quantity*Price_Per_Unit
   select * from cafe where item='sandwich'
   end;
   drop procedure Qiymet
   exec Qiymet
   @Dəyər=1,@Məhsul='Tea'

   --Odenis novune gore toplam satisi getiren prosedure

   create procedure odenis_nov
   @Nov nvarchar(50)
    as begin
	select sum(total_spent)  from cafe
	where Payment_Method=@Nov
	end;
	drop procedure odenis_nov
	 exec odenis_nov
	 @nov='Digital Wallet'
	  select * from cafe