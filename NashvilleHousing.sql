select * 
from PortfolioProject.dbo.NashvilleHousing


--Standardize Date Format
select SaleDate, convert(Date,saledate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

AlTER TABLE NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

------------------------------------------------------------

--populate property Address date
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.parcelID, a.propertyAddress, b.parcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

------------------------------------------------------

--Breakng out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from portfolioProject.dbo.NashvilleHousing

AlTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


AlTER TABLE NashvilleHousing
add propertySplitCity Nvarchar(255);

Update NashvilleHousing
Set propertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVarchar(255);

 Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVarchar(255);

 Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------

--change Y and N to Yes and No is "sold as Vacant" field
Select Distinct(soldAsVacant),COUNT(soldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by soldAsVacant
order by 2


select SoldAsVacant,
Case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SoldAsVacant=CASE when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	ElSE SoldAsVacant
	END

---------------------------------------------------------

--Remove Duplicates
with ROWNUMCTE as(
select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					)row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
--DELETE
from ROWNUMCTE
where row_num >1
--order by PropertyAddress

-------------------------------------------------------------------

--Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

AlTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN Owneraddress, TaxDistrict, PropertyAddress

AlTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

