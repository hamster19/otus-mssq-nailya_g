/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 

select a.PersonID, a.FullName
from Application.People as a 
where IsSalesperson = 1
	and not a.PersonID in (select distinct s.SalespersonPersonID from Sales.Invoices as s where InvoiceDate = convert(date,'20150704',121))

-----------------
;with Sales_Invoices 
 as
(select distinct s.SalespersonPersonID from Sales.Invoices as s where InvoiceDate = convert(date,'20150704',121) )

select a.PersonID, a.FullName
from Application.People as a 
left outer join Sales_Invoices as si on si.SalespersonPersonID = a.PersonID
where a.IsSalesperson = 1 and si.SalespersonPersonID is null

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 

select StockitemID, StockItemName, RecommendedRetailPrice 
from Warehouse.StockItems
where RecommendedRetailPrice in (select min(RecommendedRetailPrice) from Warehouse.StockItems)

select StockitemID, StockItemName, RecommendedRetailPrice 
from Warehouse.StockItems
where RecommendedRetailPrice in (select top 1 RecommendedRetailPrice from Warehouse.StockItems order by RecommendedRetailPrice)


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: 

select c.[CustomerID], c.CustomerName, c.[PhoneNumber], c.[FaxNumber], ca.CityName as DeliveryCity
from [Sales].[Customers] as c
inner join [Application].[Cities] as ca on c.DeliveryCityID = ca.CityID
where c.[CustomerID] in (select distinct CustomerID from (select top 5 with ties CustomerID from Sales.CustomerTransactions order by TransactionAmount desc) as tbl1 )

-----------------
;with Customer_Transactions
 as 
 (select top 5 with ties CustomerID, TransactionAmount from Sales.CustomerTransactions order by TransactionAmount desc)

select distinct c.[CustomerID], c.CustomerName, c.[PhoneNumber], c.[FaxNumber], ca.CityName as DeliveryCity
from [Sales].[Customers] as c
inner join [Application].[Cities] as ca on c.DeliveryCityID = ca.CityID
inner join Customer_Transactions as ct on c.[CustomerID] = ct.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO:

select distinct sc.DeliveryCityID, ca.CityName, ap.FullName
from Sales.Invoices as s
inner join Sales.InvoiceLines as si on s.InvoiceID = si.InvoiceID 
									and si.TaxAmount in (select distinct top 3 TaxAmount from Sales.InvoiceLines order by InvoiceLines.TaxAmount desc)
inner join [Sales].[Customers] as sc on s.CustomerID = sc.CustomerID
inner join [Application].Cities as ca on sc.DeliveryCityID = ca.CityID
inner join [Application].People as ap on ap.PersonID = s.PackedByPersonID


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос
set statistics io, time on;

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: 

;with TotalSumm
 as
 (SELECT  OrderLines.OrderId
		, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) TotalSummForPickedItems
	FROM Sales.Orders
	inner join Sales.OrderLines on OrderLines.OrderId = Orders.OrderId
	WHERE Orders.PickingCompletedWhen IS NOT NULL
	group by OrderLines.OrderId
  ),
  TotalSumm2
  as
  (select InvoiceLines.InvoiceID
		, SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) AS TotalSummByInvoice
   from Sales.InvoiceLines
   group by InvoiceLines.InvoiceID having SUM(Quantity*UnitPrice) > 27000
  )

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName,
	TotalSumm2.TotalSummByInvoice,
	TotalSumm.TotalSummForPickedItems 
FROM Sales.Invoices 
INNER JOIN Application.People on People.PersonID = Invoices.SalespersonPersonID
inner join TotalSumm on TotalSumm.OrderId = Invoices.OrderId
inner join TotalSumm2 on Invoices.InvoiceID = TotalSumm2.InvoiceID
ORDER BY TotalSummByInvoice DESC

------------------------------------
;with TotalSumm
 as
 (SELECT  OrderLines.OrderId
		, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) TotalSummForPickedItems
	FROM Sales.Orders
	inner join Sales.OrderLines on OrderLines.OrderId = Orders.OrderId
	WHERE Orders.PickingCompletedWhen IS NOT NULL
	group by OrderLines.OrderId
  )


SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName,
	SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) AS TotalSummByInvoice,
	TotalSumm.TotalSummForPickedItems 
FROM Sales.Invoices 
INNER JOIN Application.People on People.PersonID = Invoices.SalespersonPersonID
inner join TotalSumm on TotalSumm.OrderId = Invoices.OrderId
inner join Sales.InvoiceLines on InvoiceLines.InvoiceID = Invoices.InvoiceID
group by Invoices.InvoiceID, Invoices.InvoiceDate, People.FullName, TotalSumm.TotalSummForPickedItems 
having SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) > 27000
ORDER BY TotalSummByInvoice DESC
