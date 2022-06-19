/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

insert into [Sales].[Customers] 
		(/*[CustomerID],*/ [CustomerName] ,[BillToCustomerID] ,[CustomerCategoryID] /*,[BuyingGroupID]*/ ,[PrimaryContactPersonID]
		 /*,[AlternateContactPersonID]*/ ,[DeliveryMethodID] ,[DeliveryCityID] ,[PostalCityID]
		 ,[CreditLimit] ,[AccountOpenedDate] ,[StandardDiscountPercentage] ,[IsStatementSent] ,[IsOnCreditHold]
		 ,[PaymentDays] ,[PhoneNumber] ,[FaxNumber] /*,[DeliveryRun] ,[RunPosition]*/ ,[WebsiteURL] ,[DeliveryAddressLine1]
		 ,[DeliveryAddressLine2] ,[DeliveryPostalCode] ,[DeliveryLocation] ,[PostalAddressLine1] ,[PostalAddressLine2]
		 ,[PostalPostalCode] ,[LastEditedBy] /*,[ValidFrom] ,[ValidTo]*/)
values (/*[CustomerID],*/ 'Lea Carvalnaya' ,next value for Sequences.[CustomerID] ,1 ,/*[BuyingGroupID]*/ (select top 1 PersonID  from WideWorldImporters.Application.People where IsEmployee = 1 and IsSalesperson = 1)
		/*,[AlternateContactPersonID]*/, 3, 25608, 25608
		 , 4000, '2022-06-14', 0, 0, 0
		 , 7, '(812) 555-0100', '(812) 555-0101', /*[DeliveryRun],[RunPosition] */ 'http://www.customers.com/LeaCarvalnaya', 'apt 96'
		 , '35 industrial avenue', '195279', (SELECT TOP 1 Location FROM [Application].Cities WHERE CityID = 25608), (select 'PO Box ' + cast(ceiling( RAND()*100000) as varchar(15)) ) , 'Leaville'
		 , '511316', 1 /*,[ValidFrom] ,[ValidTo]*/ )

		,(/*[CustomerID],*/ 'Abrita Abelek' ,next value for Sequences.[CustomerID] ,(select CustomerCategoryID from  WideWorldImporters.Sales.CustomerCategories where CustomerCategoryName = 'Wholesaler'), /*[BuyingGroupID]*/ 20
		  /*,[AlternateContactPersonID]*/, (SELECT top 1 DeliveryMethodID FROM [WideWorldImporters].[Application].[DeliveryMethods] where DeliveryMethodName like '%Air Freight%'), 30195, 30195
		  , 3000, '20220618', 0, 0, 0
		  , 7, '(812) 552-0100', '(812) 552-0101', /*[DeliveryRun],[RunPosition] */ 'http://www.customers.com/AbritaAbelek', 'apt 105'
		  , '55 avenue of artists', '195277', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326), (select 'PO Box ' + cast(ceiling( RAND()*100000) as varchar(15)) ) , 'Abritaville'
		  , '311316', 1 /*,[ValidFrom] ,[ValidTo]*/ 
		)

declare @CustomerID int 
select @CustomerID = next value for Sequences.[CustomerID]

insert into [Sales].[Customers] 
		([CustomerID], [CustomerName] ,[BillToCustomerID] ,[CustomerCategoryID] /*,[BuyingGroupID]*/ ,[PrimaryContactPersonID]
		 ,[AlternateContactPersonID] ,[DeliveryMethodID] ,[DeliveryCityID] ,[PostalCityID]
		 ,[CreditLimit] ,[AccountOpenedDate] ,[StandardDiscountPercentage] ,[IsStatementSent] ,[IsOnCreditHold]
		 ,[PaymentDays] ,[PhoneNumber] ,[FaxNumber] ,[DeliveryRun] ,[RunPosition] ,[WebsiteURL] ,[DeliveryAddressLine1]
		 ,[DeliveryAddressLine2] ,[DeliveryPostalCode] ,[DeliveryLocation] ,[PostalAddressLine1] ,[PostalAddressLine2]
		 ,[PostalPostalCode] ,[LastEditedBy] /*,[ValidFrom] ,[ValidTo]*/)
values (@CustomerID, 'Abrika Mabelek' ,@CustomerID ,(select CustomerCategoryID from  WideWorldImporters.Sales.CustomerCategories where CustomerCategoryName = 'Wholesaler'), 16
		  ,16 , (SELECT top 1 DeliveryMethodID FROM [WideWorldImporters].[Application].[DeliveryMethods] where DeliveryMethodName like '%Air Freight%'), 30195, 30195
		  , 35000, '20220618', 0, 0, 0
		  , 7, '(812) 553-0100', '(812) 553-0101', '', '', 'http://www.customers.com/MAbritaAbelek', 'apt 105'
		  , '55 builders avenue', '195278', geography::STGeomFromText('LINESTRING(60.044877 30.351073, -122.343 47.656 )', 4326), (select 'PO Box ' + cast(ceiling( RAND()*100000) as varchar(15)) ) , 'Mabritaville'
		  , '311316', 1  
		)
	  , (next value for Sequences.[CustomerID], 'MAbrita MAbelek' ,next value for Sequences.[CustomerID] ,(select CustomerCategoryID from  WideWorldImporters.Sales.CustomerCategories where CustomerCategoryName = 'Wholesaler'), /*[BuyingGroupID]*/ 20
		  , NULL, (SELECT top 1 DeliveryMethodID FROM [WideWorldImporters].[Application].[DeliveryMethods] where DeliveryMethodName like '%Air Freight%'), 30195, 30195
		  , 3000, '20220618', 0, 0, 0
		  , 7, '(812) 554-0100', '(812) 554-0101', NULL, NULL, 'http://www.customers.com/loc2', 'apt 5'
		  , '55 Khudognikov street', '195279', geography::STGeomFromText('Point(60.044877 30.351073)', 4326), (select 'PO Box ' + cast(ceiling( RAND()*100000) as varchar(15)) ) , 'MAbritaville'
		  , '311320', 1 /*,[ValidFrom] ,[ValidTo]*/);

insert into [Sales].[Customers] ([CustomerID], [CustomerName] ,[BillToCustomerID] ,[CustomerCategoryID] ,[BuyingGroupID] ,[PrimaryContactPersonID]
		 ,[AlternateContactPersonID] ,[DeliveryMethodID] ,[DeliveryCityID] ,[PostalCityID]
		 ,[CreditLimit] ,[AccountOpenedDate] ,[StandardDiscountPercentage] ,[IsStatementSent] ,[IsOnCreditHold]
		 ,[PaymentDays] ,[PhoneNumber] ,[FaxNumber] ,[DeliveryRun] ,[RunPosition] ,[WebsiteURL] ,[DeliveryAddressLine1]
		 ,[DeliveryAddressLine2] ,[DeliveryPostalCode] ,[DeliveryLocation] ,[PostalAddressLine1] ,[PostalAddressLine2]
		 ,[PostalPostalCode] ,[LastEditedBy] /*,[ValidFrom] ,[ValidTo]*/)
SELECT next value for Sequences.[CustomerID] [CustomerID]
      ,'Kristi Ptrik'[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
    /*  ,[ValidFrom] ,[ValidTo]*/
  FROM [WideWorldImporters].[Sales].[Customers]
  where CustomerID = 999

select * from [Sales].[Customers] where CustomerID in ( 1064, 1065, 1072, 1073, 1074)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete from [Sales].[Customers] where CustomerID = 1064

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update [Sales].[Customers] set CustomerName = 'Patrik Patrikson' , AlternateContactPersonID = 20
where CustomerID = 1074

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

declare @Customer int = 1076; --1065

MERGE [Sales].[Customers] as tg
USING (select @Customer as CustomerID) as sr
ON
(tg.CustomerID = sr.CustomerID )
WHEN MATCHED
	THEN  UPDATE SET tg.CustomerName = 'Amrita Abele'
WHEN NOT MATCHED
	THEN INSERT (/*[CustomerID],*/ [CustomerName] ,[BillToCustomerID] ,[CustomerCategoryID] /*,[BuyingGroupID]*/ ,[PrimaryContactPersonID]
		 /*,[AlternateContactPersonID]*/ ,[DeliveryMethodID] ,[DeliveryCityID] ,[PostalCityID]
		 ,[CreditLimit] ,[AccountOpenedDate] ,[StandardDiscountPercentage] ,[IsStatementSent] ,[IsOnCreditHold]
		 ,[PaymentDays] ,[PhoneNumber] ,[FaxNumber] /*,[DeliveryRun] ,[RunPosition]*/ ,[WebsiteURL] ,[DeliveryAddressLine1]
		 ,[DeliveryAddressLine2] ,[DeliveryPostalCode] ,[DeliveryLocation] ,[PostalAddressLine1] ,[PostalAddressLine2]
		 ,[PostalPostalCode] ,[LastEditedBy] /*,[ValidFrom] ,[ValidTo]*/)
	VALUES (/*[CustomerID],*/ 'Klea Carvalnii' , @Customer,1 ,(select top 1 PersonID  from WideWorldImporters.Application.People where IsEmployee = 1 and IsSalesperson = 1)
		 , 3, 25608, 25608
		 , 4000, '2022-06-14', 0, 0, 0
		 , 7, '(812) 555-0100', '(812) 555-0101','http://www.customers.com/LeaCarvalnaya' , 'apt 96'
		 , '35 industrial avenue', '195279', (SELECT TOP 1 Location FROM [Application].Cities WHERE CityID = 25608), (select 'PO Box ' + cast(ceiling( RAND()*100000) as varchar(15)) ) , 'Leaville'
		 , '511316', 1 );

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

--SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "C:\111\Sales_Customers.txt" -T -w -t\ -S LAPTOP-G0LA48KQ\SQLDEVELOPER' 

------------------------
drop table if exists [Sales].[Customers_Version_2]

CREATE TABLE [Sales].[Customers_Version_2](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](15) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [int] NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_Customers_Version_2] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA],
 CONSTRAINT [UQ_Sales_Customers_CustomerName_Version_2] UNIQUE NONCLUSTERED 
(
	[CustomerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]


BULK INSERT [WideWorldImporters].[Sales].[Customers_Version_2]
				   FROM "C:\111\Sales_Customers.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '\',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );



select * from [Sales].[Customers_Version_2];

drop table [Sales].[Customers_Version_2]

--select USER_NAME()