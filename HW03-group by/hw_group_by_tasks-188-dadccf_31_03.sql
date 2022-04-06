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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO:
select YEAR(inv.InvoiceDate) as year_sale
	 , MONTH(inv.InvoiceDate) as month_sale
	 , AVG(invln.UnitPrice) as avg_price
	 , SUM(invln.ExtendedPrice) as sum_sale
from [WideWorldImporters].[Sales].[Invoices] as inv
inner join [WideWorldImporters].[Sales].[InvoiceLines] as invln on inv.InvoiceID = invln.InvoiceID
group by YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate)



/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: 
select YEAR(inv.InvoiceDate) as year_sale
	 , MONTH(inv.InvoiceDate) as month_sale
	 , SUM(invln.ExtendedPrice) as sum_sale
from [WideWorldImporters].[Sales].[Invoices] as inv
inner join [WideWorldImporters].[Sales].[InvoiceLines] as invln on inv.InvoiceID = invln.InvoiceID
group by YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate)
having SUM(invln.ExtendedPrice) > 10000 --все суммы > 10000 ?


/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: 
select YEAR(inv.InvoiceDate) as year_sale
	 , MONTH(inv.InvoiceDate) as month_sale
	 , invln.Description as item_sale
	 , min(inv.InvoiceDate) as first_sale
	 , SUM(invln.ExtendedPrice) as sum_sale
	 , sum(invln.Quantity) as quantity_sale
from [WideWorldImporters].[Sales].[Invoices] as inv
inner join [WideWorldImporters].[Sales].[InvoiceLines] as invln on inv.InvoiceID = invln.InvoiceID
group by YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), invln.Description 
order by YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), invln.Description

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

select tbl.month1 --MONTH(inv.InvoiceDate) as month_sale
	 , tbl.year1 --YEAR(inv.InvoiceDate) as year_sale
	 , SUM(isnull(invln.ExtendedPrice,0)) as sum_sale
from [WideWorldImporters].[Sales].[Invoices] as inv
inner join[WideWorldImporters].[Sales].[InvoiceLines] as invln on inv.InvoiceID = invln.InvoiceID
right outer join
(select month1, year1 from (values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) as t1 (month1) 
			   cross join (values (2013), (2014), (2015), (2016)) as t2 (year1)) as tbl
  on tbl.month1 = MONTH(inv.InvoiceDate) and tbl.year1 = year(inv.InvoiceDate)
group by tbl.year1, tbl.month1
having SUM(invln.ExtendedPrice) > 10000 or isnull(SUM(invln.ExtendedPrice),0) = 0
order by tbl.year1, tbl.month1

			
