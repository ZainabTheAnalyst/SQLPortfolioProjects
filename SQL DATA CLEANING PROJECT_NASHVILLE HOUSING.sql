------CLEANING DATA IN SQL------

Select *
From [PortfolioProject ].dbo.[Nashville Housing]

--Standardized Date Format 

Select SaleDate,CONVERT(date,SaleDate)
From [PortfolioProject ].dbo.[Nashville Housing]

Update [Nashville Housing]
SET SaleDate = CONVERT(date,SaleDate)

Alter Table [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing]
SET SaleDateConverted = CONVERT(date,SaleDate) 

--Populate Property Address Data 

Select PropertyAddress
From [PortfolioProject ].dbo.[Nashville Housing] 
Where PropertyAddress is Null

Select *
From [PortfolioProject ].dbo.[Nashville Housing] 
--Where PropertyAddress is Null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.[Nashville Housing] a
Join [PortfolioProject ].dbo.[Nashville Housing] b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is Null 

Update a
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.[Nashville Housing] a
Join [PortfolioProject ].dbo.[Nashville Housing] b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is Null 


-- Breaking out Address into Individual Columns(Address, City, State)
--PROPERTY ADDRESS

Select PropertyAddress
From [PortfolioProject ].dbo.[Nashville Housing] 

Select 
SUBSTRING(propertyaddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City 
From [PortfolioProject ].dbo.[Nashville Housing] 

Alter Table [Nashville Housing]
Add PropertySplitAddress nvarchar(255);

Update [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(propertyaddress,1, CHARINDEX(',',PropertyAddress)-1) 



Alter Table [Nashville Housing]
Add PropertySplitCity nvarchar(255);

Update [Nashville Housing]
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select*
from [PortfolioProject ].dbo.[Nashville Housing] 

--OWNER ADRESS

SELECT OwnerAddress
from [PortfolioProject ].dbo.[Nashville Housing] 

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from [PortfolioProject ].dbo.[Nashville Housing] 

Alter Table [Nashville Housing]
Add OwnerSplitAddress nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table [Nashville Housing]
Add OwnerSplitCity nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter Table [Nashville Housing]
Add OwnerSplitState nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y aand N to Yes and No in 'Sold as Vacant' field 

Select Distinct(SoldasVacant), Count(soldasvacant)
from [PortfolioProject ].dbo.[Nashville Housing] 
group by SoldAsVacant
order by 2

Select SoldasVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [PortfolioProject ].dbo.[Nashville Housing] 


Update [Nashville Housing]
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [PortfolioProject ].dbo.[Nashville Housing] 


--Removing Duplicates 

WITH RowNumCTE AS(
select *,
       ROW_NUMBER() over (
	   Partition by ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by 
					  UniqueID
					  ) as row_num
from [PortfolioProject ].dbo.[Nashville Housing] 
--order by ParcelID
)
Delete *
FROM RowNumCTE
WHERE row_num >1

-- Delete Unused Columns 


select*
from [PortfolioProject ].dbo.[Nashville Housing] 

Alter Table [PortfolioProject ].dbo.[Nashville Housing] 
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress, SaleDate

