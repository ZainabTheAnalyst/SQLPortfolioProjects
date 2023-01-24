MAVEN FUZZY FACTORY 
Analyzing & Optimising business's marketing channels,website and product portfolio.

THE SITUATION: The CEO is close to securing a second round of funding & she needs your help to tell a compelling story of your company's 
rapid growth to the investors.

THE OBJECTIVE: Use SQL to extract and analyze website traffic performance data. Then dive into the marketing channel activities and the website 
improvements that have contribute to company's success to date.


Use mavenfuzzyfactory;
/*
1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
trended by quarter for the life of the business? Since the most recent quarter is incomplete, 
you can decide how to handle it.
*/ 
SELECT
      YEAR(ws.created_at) AS yr,
      QUARTER(ws.created_at) AS quarter,
      COUNT(DISTINCT ws.website_session_id) AS sessions,
      COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
  LEFT JOIN orders o ON ws.website_session_id = o.website_session_id      
WHERE ws.created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2; -- Dramatic growth from the start, about 100 times that many orders.

/*
2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures 
since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 

*/
SELECT
      YEAR(ws.created_at) AS yr,
      QUARTER(ws.created_at) AS quarter,
      COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS session_to_order_cvr,
      SUM(o.price_usd)/COUNT(DISTINCT o.order_id) AS revenue_per_order,
      SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session 
FROM website_sessions ws
  LEFT JOIN orders o ON ws.website_session_id = o.website_session_id      
WHERE ws.created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2;  /*Efficiency has improved in terms of cvr and more revenue per order because of cross selling more products 
                 and revenue per sessions has increased whoch means we can bid higher for paid marketeing 
                 so more ppl will see our products/ads.*/

/*
3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/
SELECT
      YEAR(ws.created_at) AS yr,
      QUARTER(ws.created_at) AS qtr,
      COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND utm_campaign ='nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
	  COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND utm_campaign ='nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
      COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders,
      COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
      COUNT(DISTINCT CASE WHEN utm_source IS NULL AND utm_campaign IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions ws
  LEFT JOIN orders o ON ws.website_session_id = o.website_session_id      
WHERE ws.created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2; -- Business has become much less dependant on paid g search non brand campaigns and has started to build its own brand (organic and direct type in traffic).

/*
4. Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/
SELECT 
      YEAR(ws.created_at) AS yr,
      QUARTER(ws.created_at) AS qtr,
	  COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND utm_campaign ='nonbrand' THEN o.order_id ELSE NULL END)
           /COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND utm_campaign ='nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_cvr,
	  COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND utm_campaign ='nonbrand' THEN o.order_id ELSE NULL END)
           /COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND utm_campaign ='nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_cvr,
      COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END)
           /COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_search_cvr,
      COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END)
		   /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_cvr,
      COUNT(DISTINCT CASE WHEN utm_source IS NULL AND utm_campaign IS NULL THEN o.order_id ELSE NULL END)
           / COUNT(DISTINCT CASE WHEN utm_source IS NULL AND utm_campaign IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_cvr
FROM website_sessions ws
  LEFT JOIN orders o ON ws.website_session_id = o.website_session_id      
WHERE ws.created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2; -- All of these have seen substantial improvement since what they were before so it shows efficiency has improved.

/*
5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/
SELECT
	YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY 1,2
ORDER BY 1,2; -- The revenue and margin increased all the products esp during OCT/NOV due to the hoilday season.

/*
6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to 
the /products page, and show how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved.
*/
-- first, identifying all the views of the /products page
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id, 
    website_pageview_id, 
    created_at AS saw_product_page_at

FROM website_pageviews 
WHERE pageview_url = '/products';


SELECT 
	YEAR(saw_product_page_at) AS yr, 
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page, 
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page, 
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = products_pageviews.website_session_id -- same session
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id -- they had another page AFTER(only if they had another session after) 
	LEFT JOIN orders 
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2; -- Both metrics increased, additional proucts have improved the overall perfor,ace of the business.

/*
7. We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/
-- Find out when 4th product was made available.
CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05'; -- when the 4th product was added

SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0; -- only bringing in cross-sells
        
SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
(
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0 -- only bringing in cross-sells
) AS primary_w_cross_sell
GROUP BY 1; -- Product 4 was cross sold more to all three of the other products probably cause it was sold at a lower price so it will contribute to 
	       higher AOV for the business.



































      
      







