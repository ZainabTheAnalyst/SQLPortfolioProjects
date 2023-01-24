MAVEN FUZZY FACTORY 
Analyzing & Optimising business's marketing channels,website and product portfolio.

THE SITUATION:Maven fuzzy factory has been live for 8 months and the CEOhas to present company performance report to the board next week.

THE OBJECTIVE:Extract & analyze website traffic and performance data to quantify company's growth and to tell the story of how you have been able to generate that
growth.

USE mavenfuzzyfactory;

/*
1.	Gsearch seems to be the biggest driver of our business. Could you pull monthly 
trends for gsearch sessions and orders so that we can showcase the growth there? 
*/ 
SELECT 
      YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
      COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
      COUNT(DISTINCT orders.order_id) AS orders,
      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions    
  LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id 
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;
  
/*
2.	Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand 
and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. 
*/ 
SELECT 
      YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
	  COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions, 
      COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
      COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions, 
      COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM website_sessions    
  LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id 
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

/*
3.	While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
I want to flex our analytical muscles a little and show the board we really know our traffic sources. 
*/ 
SELECT 
      YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
      COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
      COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
      COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_session,
      COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders      
FROM website_sessions
  LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;

/*
4.	I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/ 
SELECT DISTINCT -- To find different channels 
    utm_source,
    utm_campaign, 
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';

SELECT
	YEAR(website_sessions.created_at) AS yr, 
    MONTH(website_sessions.created_at) AS mo, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

/*
5.	I’d like to tell the story of our website performance improvements over the course of the first 8 months. 
Could you pull session to order conversion rates, by month? 

*/ 
SELECT
	YEAR(website_sessions.created_at) AS year, 
    MONTH(website_sessions.created_at) AS month, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 
    COUNT(DISTINCT orders.order_id) AS orders, 
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate    
FROM website_sessions
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

/*
6.	For the gsearch lander test, please estimate the revenue that test earned us 
(Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use 
nonbrand sessions and revenue since then to calculate incremental value)
*/ 
-- Find out the first_pageview when the lander-1 test was carried out 
SELECT 
      website_session_id,
      MIN(website_pageview_id) AS first_pv,
      pageview_url
FROM website_pageviews
WHERE pageview_url = '/lander-1'
GROUP BY 1,3;      -- min first_pv for lander-1 = 23504

SELECT 
      wp.pageview_url, 
      COUNT(DISTINCT ws.website_session_id) AS sessions,
	  COUNT(DISTINCT o.order_id) AS orders, 
      COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS CVR
FROM website_sessions AS ws 
  LEFT JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
  LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source='gsearch' AND  ws.utm_campaign='nonbrand' AND wp.pageview_url IN ('/lander-1', '/home')
AND ws.created_at < '2012-07-28' AND wp.website_pageview_id >= 23504
GROUP BY 1; -- Increment in CVR is 0.0088

-- Find out the max/recent pageview for /home 
SELECT 
      wp.pageview_url,
      MAX(ws.website_session_id) AS most_recent_session_home
FROM website_sessions AS ws
  LEFT JOIN website_pageviews AS wp ON wp.website_session_id = ws.website_session_id 
WHERE wp.pageview_url = '/home' AND ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
AND ws.created_at < '2012-11-27'
GROUP BY 1; -- last home session = 17145

-- Find sessions after the last home session
SELECT 
      COUNT(DISTINCT website_session_id) 
FROM website_sessions
WHERE utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
AND created_at < '2012-11-27'  AND website_session_id > 17145; -- 22972 sessions since the lander-1 test 

-- Multiply no. of sessions with incremental cvr to find the incremental orders that is 22972*0.0088 = 202 incremental orders since 2012-07-29(when test concluded)

/*
7.	For the landing page test you analyzed previously, it would be great to show a full conversion funnel 
from each of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/ 
SELECT
	ws.website_session_id, 
    wp.pageview_url, 
    -- wp.created_at AS pageview_created_at, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions AS ws
	LEFT JOIN website_pageviews AS wp
		ON ws.website_session_id = wp.website_session_id
WHERE ws.utm_source = 'gsearch' 
	AND ws.utm_campaign = 'nonbrand' 
    AND ws.created_at < '2012-07-28'
		AND ws.created_at > '2012-06-19'
ORDER BY 
	ws.website_session_id,
    wp.created_at;





CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
	website_session_id, 
    MAX(homepage) AS saw_homepage, 
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS product_made_it, 
    MAX(mrfuzzy_page) AS mrfuzzy_made_it, 
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	ws.website_session_id, 
    wp.pageview_url, 
    -- wp.created_at AS pageview_created_at, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions AS ws
	LEFT JOIN website_pageviews AS wp
		ON ws.website_session_id = wp.website_session_id
WHERE ws.utm_source = 'gsearch' 
	AND ws.utm_campaign = 'nonbrand' 
    AND ws.created_at < '2012-07-28'
		AND ws.created_at > '2012-06-19'
ORDER BY 
	ws.website_session_id,
    wp.created_at
) AS pageview_level

GROUP BY 
	website_session_id;

 

-- then this would produce the final output, part 1
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'check logic' 
	END AS segment, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagged 
GROUP BY 1
;



-- then this as final output part 2 - click rates

SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'check logic' 
	END AS segment, 
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flagged
GROUP BY 1
;

/*
8.	I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated 
from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number 
of billing page sessions for the past month to understand monthly impact.
*/ 
SELECT 
      wp.website_session_id,
      wp.pageview_url AS billing_version_seen,
      o.order_id,
      o.price_usd
FROM website_pageviews wp 
  LEFT JOIN orders o ON wp.website_session_id = o.website_session_id 
WHERE wp.pageview_url IN ('/billing' , 'billing-2')
AND wp.created_at > '2012-09-10' AND wp.created_at < '2012-11-10';

SELECT 
      billing_version_seen,
      COUNT(DISTINCT website_session_id) AS sessions,
      SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM ( SELECT 
      wp.website_session_id,
      wp.pageview_url AS billing_version_seen,
      o.order_id,
      o.price_usd
FROM website_pageviews wp 
  LEFT JOIN orders o ON wp.website_session_id = o.website_session_id 
WHERE wp.pageview_url IN ('/billing' , '/billing-2')
AND wp.created_at > '2012-09-10' AND wp.created_at < '2012-11-10') AS billing_pageview_and_orders
GROUP BY 1;

-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- INCREASE: $8.51 per billing page view

SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month 
 
-- 1,193  billing sessions in the past month
-- INCREASE: $8.51 per billing page view
-- VALUE OF BILLING TEST: $10,152 over the past month

















