* import the dataset;
proc import out=customer datafile="D:\SAS\course data-20170610T011252Z-001\course data\Project\customers.xlsx" dbms=xlsx;
sheet="customer";
getnames=yes;
run;

proc import out=product datafile="D:\SAS\course data-20170610T011252Z-001\course data\Project\products.xlsx" dbms=xlsx;
sheet="product";
getnames=yes;
run;

proc import out=return datafile="D:\SAS\course data-20170610T011252Z-001\course data\Project\returns.xlsx" dbms=xlsx;
sheet="Sheet1";
getnames=yes;
run;

proc import out=sale datafile="D:\SAS\course data-20170610T011252Z-001\course data\Project\sales.xlsx" dbms=xlsx;
sheet="cusproID";
getnames=yes;
run;

* merge the tables;
proc sql;
create table mg as 
select a.*, b.*, c.*
from sale as a 
left join customer as b
on a.customer_id=b.id
left join product as c 
on a.product_id=c.id
;quit;

* show first 10 rows;
proc print data=mg(obs=10); run;

* regional sale distribution;
proc sql;
create table prosale as 
select province, sum(Sales) as sale
from mg
group by province
;quit;

* regional sale proportion;
proc sql;
create table propct as 
select province, sale, sale/sum(sale) as pct
from prosale
order by pct descending
;quit;

* show the top five region by sale;
proc print data=propct(obs=5); run;

* pie plot;
proc gchart data=mg;
pie province /
        discrete
        sumvar=sales;
run;

* how much profit for each customer;
proc sql;
create table percus as 
select customer_name, sum(profit) as profit
from mg
group by customer_name
order by profit descending 
;quit;

* show top ten customers by profit;
proc print data=percus(obs=10); run;

* figure out the concentration of profit by Herfindal Index;
proc sql;
create table herfin as
select customer_name, sum(profit) as profit
from mg
group by customer_name
;quit;

proc sql;
create table herfin_pct as 
select *, profit/sum(profit) as pct
from herfin
;quit;

* compared with equally distribution;
proc sql;
select sum(pct*pct) as herfindal, 1/count(*) as benchmark
from herfin_pct
;quit;

* figure out the products with highest returned rate;
proc sql;
create table mgreturn as
select a.*, b.product_name
from return as a 
left join mg as b
on a.order_id=b.order_id
;quit;

* group the returned products;
proc sql;
create table groupreturn as 
select product_name, count(*) as returns
from mgreturn
group by product_name
order by returns descending
;quit;

* show the top 10 products with highest returned rate;
proc print data=groupreturn(obs=10); run;

/* some data is missing
*/