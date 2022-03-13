/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO: 
select [StockItemID], [StockItemName]
from [WideWorldImporters].[Warehouse].[StockItems]
where [StockItemName] like '%urgent%' or [StockItemName] like 'animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO:
select S.SupplierID, S.SupplierName
from [WideWorldImporters].[Purchasing].[Suppliers] as S 
left outer join [WideWorldImporters].[Purchasing].[PurchaseOrders] as PO on S.SupplierID = PO.SupplierID 
where PO.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/


TODO: 

--3.1 хотя бы 1 товар в заказе с OL.Quantity > 20 or OL.UnitPrice > 100
set language Russian;
select O.OrderID 
	 , convert(varchar(10), O.OrderDate, 104) as [Дата_заказа] --вопрос с сортировкой -из-за varchar неправильно сортирует в order by
	 , DATENAME(m, O.OrderDate) as [Месяц_заказа]
	 , case when DATEPART(m, O.OrderDate) between 1 and 6 then 1 else 2 end as [Квартал]
	 , case when DATEPART(m, O.OrderDate) between 1 and 4 then 1 
			when DATEPART(m, O.OrderDate) between 5 and 8 then 2
			else 3 end as [Треть года] 
	 , C.CustomerName as [Имя_заказчика]
from [WideWorldImporters].[Sales].[Orders] as O
inner join [WideWorldImporters].[Sales].Customers as C on O.CustomerID = C.CustomerID
left outer join [WideWorldImporters].[Sales].[OrderLines] as OL on O.OrderID = OL.OrderID
where (OL.Quantity > 20 or OL.UnitPrice > 100) 
		and O.PickingCompletedWhen is not null
order by [Квартал], [Треть года], O.OrderDate --иначе сортирует не по дате
offset 1000 rows fetch next 100 rows only

--3.2 Все товары в заказе удовлетворяют условиям OL.Quantity > 20 or OL.UnitPrice > 100
set language Russian;
select O.OrderID 
	 , convert(varchar(10), O.OrderDate, 104) as [Дата_заказа] --вопрос с сортировкой -из-за varchar неправильно сортирует в order by
	 , DATENAME(m, O.OrderDate) as [Месяц_заказа]
	 , case when DATEPART(m, O.OrderDate) between 1 and 6 then 1 else 2 end as [Квартал]
	 , case when DATEPART(m, O.OrderDate) between 1 and 4 then 1 
			when DATEPART(m, O.OrderDate) between 5 and 8 then 2
			else 3 end as [Треть года] 
	 , C.CustomerName as [Имя_заказчика]
from [WideWorldImporters].[Sales].[Orders] as O
inner join [WideWorldImporters].[Sales].Customers as C on O.CustomerID = C.CustomerID
left outer join (select OL.OrderID
				 from [WideWorldImporters].[Sales].[OrderLines] as OL
				 group by OL.OrderID having sum(OL.Quantity) % 20 = 0 or sum(OL.UnitPrice) % 100 = 0
				) as OL1 on O.OrderID = OL1.OrderID
where O.PickingCompletedWhen is not null
order by [Квартал], [Треть года], O.OrderDate --иначе сортирует не по дате
offset 1000 rows fetch next 100 rows only


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO: 
select DM.DeliveryMethodName as [способ доставки]
	 , PO.ExpectedDeliveryDate as [дата доставки]
	 , S.SupplierName as [имя поставщика]
	 , P.FullName as [контактное лицо]
from Purchasing.PurchaseOrders as PO
inner join Purchasing.Suppliers as S on PO.SupplierID = S.SupplierID
inner join Application.DeliveryMethods as DM on PO.DeliveryMethodID = DM.DeliveryMethodID
inner join Application.People as P on PO.ContactPersonID = P.PersonID


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO: 

select top 10 O.OrderID 
			, CustomerName as [имя клиента]
			, P.FullName as [имя сотрудника]
			, OrderDate as [дата заказа] 
FROM [WideWorldImporters].[Sales].[Orders] as O
inner join [WideWorldImporters].[Sales].[Customers] as C on O.CustomerID = C.CustomerID
inner join Application.People as P on O.SalespersonPersonID = P.PersonID
order by O.OrderDate desc, O.OrderID desc


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO: 
select distinct C.CustomerID as [id клиента]
	 , PhoneNumber as [телефон клиента]
from [WideWorldImporters].[Sales].[Orders] as O
inner join [WideWorldImporters].[Sales].[Customers] as C on O.CustomerID = C.CustomerID
inner join [Sales].[OrderLines] as OL on O.OrderID = OL.OrderID
inner join [WideWorldImporters].[Warehouse].[StockItems] as S on OL.StockItemID = S.StockItemID and StockItemName = 'Chocolate frogs 250g'


