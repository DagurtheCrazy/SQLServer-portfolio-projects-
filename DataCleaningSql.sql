select * 
from PortfolioProject..NashvilleHousing 
order by UniqueID;

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing;

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted =convert(date,SaleDate);


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a 
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a 
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


select PropertyAddress
from PortfolioProject..NashvilleHousing;

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing;

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1);

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress));


select OwnerAddress
from PortfolioProject..NashvilleHousing;

select SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as Address,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1,CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress) +1)-CHARINDEX(',',OwnerAddress) -1) as City,
SUBSTRING(OwnerAddress,CHARINDEX(' ',OwnerAddress,CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress) +1)),CHARINDEX(' ',OwnerAddress) -1) as State
from PortfolioProject..NashvilleHousing;

select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing;

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3);

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity =PARSENAME(replace(OwnerAddress,',','.'),2);

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState =PARSENAME(replace(OwnerAddress,',','.'),1);

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case  when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
end
from PortfolioProject..NashvilleHousing;

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case  when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
end;

with RowNumCTE as (
select *,
ROW_NUMBER() over (
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order by UniqueId
					) as row_num
from PortfolioProject..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1;


select * from PortfolioProject..NashvilleHousing;

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress,OwnerAddress,TaxDistrict;

alter table PortfolioProject..NashvilleHousing
drop column SaleDate;