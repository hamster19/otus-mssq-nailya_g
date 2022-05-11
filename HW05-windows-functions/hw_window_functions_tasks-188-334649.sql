/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
;with SummInvoiceMonth
 as
 (select i.CustomerID
	   , sum(il.Quantity*il.UnitPrice) as SummMonth
	   , dateadd(d, -1, dateadd(m,DATEDIFF(m, 0, i.InvoiceDate) + 1, 0)) as dat -- последний день месяца
  FROM [Sales].[Invoices] as i
  inner join [Sales].[InvoiceLines] as il on i.InvoiceID = il.InvoiceID
  group by i.CustomerID ,dateadd(d, -1, dateadd(m,DATEDIFF(m, 0, i.InvoiceDate) + 1, 0))
  ),
 SummInvoice
 as 
 (select i.InvoiceID
		, i.CustomerID
		, i.InvoiceDate
		, sum(il.Quantity*il.UnitPrice) as SummInvoice
 FROM [Sales].[Invoices] as i
 inner join [Sales].[InvoiceLines] as il on i.InvoiceID = il.InvoiceID
 where i.InvoiceDate >= '20150101'
 group by i.InvoiceID, i.CustomerID, i.InvoiceDate
 )

 select si.InvoiceID
	 , c.CustomerName
	 , si.InvoiceDate
	 , si.SummInvoice
	 , sum(sim.SummMonth) as SummInvoiceMonth
from SummInvoiceMonth as sim
left outer join SummInvoice as si on si.CustomerID = sim.CustomerID and dateadd(d, -1, dateadd(m,DATEDIFF(m, 0, si.InvoiceDate) + 1, 0)) >= sim.dat
inner join [Sales].[Customers] as c on si.CustomerID = c.CustomerID
group by si.InvoiceID, c.CustomerName, si.InvoiceDate, si.SummInvoice
order by c.CustomerName, InvoiceDate

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
select tbl1.InvoiceID
		, c.CustomerName
		, tbl1.InvoiceDate
		, tbl1.InvSum
		, max(tbl1.InvSumM) over (partition by tbl1.CustomerID, year(tbl1.InvoiceDate), month(tbl1.InvoiceDate)) as InvSumMonth
from ( select i.InvoiceID
			, i.CustomerID
			, i.InvoiceDate
			, il.InvSum
			, sum(il.InvSum) over (partition by i.CustomerID order by i.InvoiceDate rows between UNBOUNDED PRECEDING and CURRENT ROW ) as InvSumM
		FROM [Sales].[Invoices] as i
		inner join (select sum(Quantity*UnitPrice) as InvSum, InvoiceID
					from [Sales].[InvoiceLines]
					group by InvoiceID) as il on i.InvoiceID = il.InvoiceID
	) as tbl1
inner join [Sales].[Customers] as c on tbl1.CustomerID = c.CustomerID
where tbl1.InvoiceDate >= '20150101'
order by c.CustomerName, tbl1.InvoiceDate

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
select tbl1.StockItemName
	 , monthsale
	 , quantitysale
from ( select st.StockItemName
			, month(i.InvoiceDate) as monthsale
			, sum(il.Quantity) as quantitysale
			, row_number() over (partition by month(i.InvoiceDate) order by sum(il.Quantity) desc) as numb
		FROM [Sales].[Invoices] as i
		inner join [Sales].[InvoiceLines] as il on i.InvoiceID = il.InvoiceID
		inner join Warehouse.StockItems as st on il.StockItemID = st.StockItemID
		where year(i.InvoiceDate) = 2016
		group by st.StockItemName, month(i.InvoiceDate) ) as tbl1
where tbl1.numb in (1, 2)
order by monthsale

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select StockItemID, StockItemName, Brand, UnitPrice
	 , row_number() over (partition by substring(StockItemName, 1, 1) order by StockItemName desc) as numb
	 , sum(QuantityPerOuter) over () as quantity_all
	 , sum(QuantityPerOuter) over (partition by substring(StockItemName, 1, 1)) as quantity_numb
	 , lead(StockItemID) over (order by StockItemName desc) as numb_lead
	 , lag(StockItemID) over (order by StockItemName desc) as numb_lag
	 , LAG(StockItemName, 2, 'No items') over (order by StockItemName desc) as name_lag_2
	 , NTILE(30) over (order by TypicalWeightPerUnit) as numb_group
from Warehouse.StockItems

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
 select SalespersonPersonID, LastName, CustomerID, CustomerName, InvoiceDate, Summ
 from ( select inv.SalespersonPersonID
				, replace(p.FullName, p.PreferredName + ' ', '') as LastName
			    , inv.CustomerID
			    , c.CustomerName
			    , inv.InvoiceDate
			    , invl.Summ
				, max(inv.InvoiceDate) over (partition by SalespersonPersonID) as num
		from Sales.Invoices as inv
		inner join (select invoiceID, sum(Quantity* UnitPrice) as Summ from Sales.InvoiceLines group by InvoiceID) as invl on inv.InvoiceID = invl.InvoiceID
		inner join Sales.Customers as c on c.CustomerID = inv.CustomerID
		inner join [Application].[People] as p on p.PersonID = inv.SalespersonPersonID --and [IsSalesperson] = 1
		) as tbl
 where tbl.num = tbl.InvoiceDate 

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
select tbl.CustomerID, tbl.CustomerName, tbl.StockItemID, tbl.StockItemName, tbl.UnitPrice, tbl.InvoiceDate
from ( select inv.CustomerID
			, c.CustomerName
			, invl.StockItemID
			, s.StockItemName
			, invl.UnitPrice
			, inv.InvoiceDate
			, LEAD (invl.UnitPrice, 2, -1) over (partition by inv.CustomerID order by invl.UnitPrice) as max2
		from Sales.Invoices as inv
		inner join Sales.InvoiceLines as invl on inv.InvoiceID = invl.InvoiceID
		inner join Sales.Customers as c on c.CustomerID = inv.CustomerID
		inner join Warehouse.StockItems as s on s.StockItemID = invl.StockItemID
	) as tbl
where tbl.max2 = -1
order by CustomerID, UnitPrice

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 