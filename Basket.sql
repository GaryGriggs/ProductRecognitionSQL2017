use Basket

/*
0.  Get data file.
0.1  Create a folder named "Basket" on the C drive.
0.2  Download and save receipts.csv to the Basket folder.
0.3  Create a database named "Basket".

The receipts.csv file is a reformatted version of the Groceries Data Set that can be found here:
http://www.salemmarafi.com/code/market-basket-analysis-with-r/comment-page-1/
*/

/*
1.  Create table for csv import.
*/
create table Basket
(
ReceiptID [int] not null,
Item [varchar](50) not null
)

/*
2.  Import file
*/
BULK INSERT Basket 
   FROM 'c:\basket\receipts.csv'  
   WITH   
      (  
         FIELDTERMINATOR =',',  
         ROWTERMINATOR ='\n'  
      );  

/*
3.  Create node and edge tables
*/
create table Item
(
Item [varchar](50)
) as node

create table Receipt
(
ReceiptID [int]
) as node

create table Includes
(
AddDate datetime
) as edge

/*
4.  Load node and edge tables
*/
insert Item
(Item)
select distinct Item
from Basket

insert Receipt
(ReceiptID)
select distinct ReceiptID
from Basket

insert Includes
($from_id, $to_id,adddate)
select r.$node_id,i.$node_id,getdate()
from Basket b
join Item i on b.Item=i.Item
join Receipt r on b.ReceiptID=r.ReceiptID

/*
5.  Query top 10 items most purchased with your item
*/
select top 10 LikeItem.Item,Count(*)
from Item as LikeItem,
Includes as LikeItemIncludes,
Receipt as CommonReceipt,
Includes as MyItemIncludes,
Item as MyItem
where MyItem.Item like 'whole milk'
and match(LikeItem<-(LikeItemIncludes)-CommonReceipt-(MyItemIncludes)->MyItem)
and LikeItem.Item<>MyItem.Item
group by LikeItem.Item
order by count(*) desc