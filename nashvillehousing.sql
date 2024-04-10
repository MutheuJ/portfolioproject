
--data cleaning
select *
from PortfolioProject..nashvillehousing

-- standardize date format

Alter Table PortfolioProject..NashvilleHousing 
Alter Column SaleDate Date

--populate property address
select *
from PortfolioProject..nashvillehousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..nashvillehousing a
join PortfolioProject..nashvillehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..nashvillehousing a
join PortfolioProject..nashvillehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out into individual columns(address, city, state)
select PropertyAddress
from PortfolioProject..nashvillehousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len (PropertyAddress))as Address
from PortfolioProject..nashvillehousing

--- removing comma in propertyaddress
update PortfolioProject..nashvillehousing
set PropertySplitAddress=parsename (replace(PropertySplitAddress,',', ' '), 1)


alter table nashvillehousing
add PropertySplitAddress nvarchar(255);
update PortfolioProject..nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))

alter table nashvillehousing
add PropertySplitCity nvarchar(255);
update PortfolioProject..nashvillehousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len (PropertyAddress))

---solution 2 splitting information into different columns

select
parsename (replace(OwnerAddress,',', '.'), 3),
parsename (replace(OwnerAddress,',', '.'), 2),
parsename (replace(OwnerAddress,',', '.'), 1)
from PortfolioProject..nashvillehousing


alter table nashvillehousing
add ownersplitaddress nvarchar(255);

update PortfolioProject..nashvillehousing
set ownersplitaddress =parsename (replace(OwnerAddress,',', '.'), 3)

alter table PortfolioProject..nashvillehousing
add ownersplitcity nvarchar(255);

update PortfolioProject..nashvillehousing
set ownersplitcity =parsename (replace(OwnerAddress,',', '.'), 2)

alter table nashvillehousing
add ownersplitstate nvarchar(255);

update PortfolioProject..nashvillehousing
set ownersplitstate =parsename (replace(OwnerAddress,',', '.'), 1)


--change y and n to yes and no in 'sold as vacant' field

select distinct (SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..nashvillehousing

update PortfolioProject..nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

--remove duplicates
with RowNumcte as (
select *,
ROW_NUMBER()over(
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by 
			UniqueID) 
			row_num
from PortfolioProject..nashvillehousing
--order by ParcelID
)
delete
from RowNumcte
where row_num > 1
--order by PropertyAddress

--delete unused columns

alter table nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

select *
from PortfolioProject..nashvillehousing

