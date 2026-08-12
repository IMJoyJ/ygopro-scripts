--RR－アーセナル・ファルコン
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只鸟兽族·4星怪兽特殊召唤。
-- ②：持有「急袭猛禽」怪兽作为超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ③：持有「急袭猛禽」怪兽作为超量素材的这张卡被送去墓地的场合才能发动。从额外卡组把「急袭猛禽-武库猎鹰」以外的1只「急袭猛禽」超量怪兽特殊召唤，把这张卡作为那超量素材。
function c96157835.initial_effect(c)
	-- 添加超量召唤手续：7星怪兽×2
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只鸟兽族·4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96157835,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c96157835.spcost1)
	e1:SetTarget(c96157835.sptg1)
	e1:SetOperation(c96157835.spop1)
	c:RegisterEffect(e1)
	-- ②：持有「急袭猛禽」怪兽作为超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(c96157835.ctcon)
	e2:SetValue(c96157835.ctval)
	c:RegisterEffect(e2)
	-- ③：持有「急袭猛禽」怪兽作为超量素材的这张卡被送去墓地的场合才能发动。从额外卡组把「急袭猛禽-武库猎鹰」以外的1只「急袭猛禽」超量怪兽特殊召唤，把这张卡作为那超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96157835,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c96157835.spcon2)
	e3:SetTarget(c96157835.sptg2)
	e3:SetOperation(c96157835.spop2)
	c:RegisterEffect(e3)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c96157835.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的特殊召唤过滤条件：卡组中的鸟兽族·4星怪兽
function c96157835.spfilter1(c,e,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空位及卡组中是否存在符合条件的怪兽）
function c96157835.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的鸟兽族·4星怪兽
		and Duel.IsExistingMatchingCard(c96157835.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的运行空间（从卡组特殊召唤1只鸟兽族·4星怪兽）
function c96157835.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的鸟兽族·4星怪兽
	local g=Duel.SelectMatchingCard(tp,c96157835.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：原本是怪兽卡的「急袭猛禽」卡
function c96157835.ctfilter(c)
	return c:IsSetCard(0xba) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
-- 效果②的适用条件：这张卡持有「急袭猛禽」怪兽作为超量素材
function c96157835.ctcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(c96157835.ctfilter,1,nil)
end
-- 效果②的追加攻击次数：超量素材中「急袭猛禽」怪兽的数量减1
function c96157835.ctval(e,c)
	return e:GetHandler():GetOverlayGroup():FilterCount(c96157835.ctfilter,nil)-1
end
-- 效果③的发动条件：持有「急袭猛禽」怪兽作为超量素材的这张卡从怪兽区域送去墓地
function c96157835.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(c96157835.ctfilter,1,nil) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果③的特殊召唤过滤条件：额外卡组中「急袭猛禽-武库猎鹰」以外的「急袭猛禽」超量怪兽
function c96157835.spfilter2(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and not c:IsCode(96157835) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤所需的可用区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的发动准备（检查额外卡组中是否存在符合条件的怪兽，以及自身是否能作为超量素材叠放）
function c96157835.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只满足条件的「急袭猛禽」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96157835.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 设置连锁处理的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁处理的操作信息：墓地的这张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果③的运行空间（从额外卡组特殊召唤1只「急袭猛禽」超量怪兽，并将这张卡作为其超量素材）
function c96157835.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「急袭猛禽」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c96157835.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的超量怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将墓地的这张卡作为超量素材叠放在特殊召唤的怪兽下面
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
