--ガスタへの追風
-- 效果：
-- 「薰风」怪兽才能装备。这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽不会被对方的效果破坏。
-- ②：可以把装备怪兽的等级·阶级的以下效果发动。
-- ●4以下：和装备怪兽种族不同的1只「薰风」怪兽从卡组特殊召唤。
-- ●5以上：从卡组把1只1星调整特殊召唤。
-- ③：把墓地的这张卡除外，从手卡丢弃1只风属性怪兽才能发动。从卡组把1张「薰风」魔法·陷阱卡加入手卡。
function c1187243.initial_effect(c)
	-- 装备效果，可以装备到「薰风」怪兽，且装备时会将目标怪兽设置为装备对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1187243.target)
	e1:SetOperation(c1187243.operation)
	c:RegisterEffect(e1)
	-- 装备对象限制，只能装备到「薰风」怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c1187243.eqlimit)
	c:RegisterEffect(e2)
	-- 装备效果，使装备怪兽不会被对方的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置装备怪兽不会被对方效果破坏的过滤函数
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：可以把装备怪兽的等级·阶级的以下效果发动。●4以下：和装备怪兽种族不同的1只「薰风」怪兽从卡组特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1187243,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,1187243)
	e4:SetCondition(c1187243.spcon1)
	e4:SetTarget(c1187243.sptg1)
	e4:SetOperation(c1187243.spop1)
	c:RegisterEffect(e4)
	-- ②：可以把装备怪兽的等级·阶级的以下效果发动。●5以上：从卡组把1只1星调整特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(1187243,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,1187243)
	e5:SetCondition(c1187243.spcon2)
	e5:SetTarget(c1187243.sptg2)
	e5:SetOperation(c1187243.spop2)
	c:RegisterEffect(e5)
	-- ③：把墓地的这张卡除外，从手卡丢弃1只风属性怪兽才能发动。从卡组把1张「薰风」魔法·陷阱卡加入手卡
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(1187243,2))
	e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,1187244)
	e6:SetCost(c1187243.thcost)
	e6:SetTarget(c1187243.thtg)
	e6:SetOperation(c1187243.thop)
	c:RegisterEffect(e6)
end
-- 装备对象限制函数，判断是否为「薰风」怪兽
function c1187243.eqlimit(e,c)
	return c:IsSetCard(0x10)
end
-- 过滤函数，用于筛选「薰风」怪兽
function c1187243.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10)
end
-- 装备效果的目标选择函数
function c1187243.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1187243.filter(chkc) end
	-- 判断是否满足装备目标选择条件
	if chk==0 then return Duel.IsExistingTarget(c1187243.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备目标
	Duel.SelectTarget(tp,c1187243.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数
function c1187243.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
-- ②效果的发动条件函数，判断装备怪兽等级或阶级是否小于等于4
function c1187243.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:IsLevelBelow(4) or ec:IsRankBelow(4))
end
-- ②效果的特殊召唤过滤函数，筛选种族不同的「薰风」怪兽
function c1187243.spfilter1(c,e,tp,race)
	return not c:IsRace(race) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的特殊召唤目标选择函数
function c1187243.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断是否满足②效果的特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c1187243.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,ec:GetRace()) end
	-- 设置②效果的特殊召唤处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的特殊召唤处理函数
function c1187243.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and ec:IsFaceup() and c:IsRelateToEffect(e) then
		-- 提示玩家选择特殊召唤目标
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择特殊召唤目标
		local g=Duel.SelectMatchingCard(tp,c1187243.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec:GetRace())
		if g:GetCount()>0 then
			-- 执行特殊召唤操作
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件函数，判断装备怪兽等级或阶级是否大于等于5
function c1187243.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:IsLevelAbove(5) or ec:IsRankAbove(5))
end
-- ②效果的特殊召唤过滤函数，筛选1星调整
function c1187243.spfilter2(c,e,tp)
	return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的特殊召唤目标选择函数
function c1187243.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c1187243.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置②效果的特殊召唤处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的特殊召唤处理函数
function c1187243.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择特殊召唤目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c1187243.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的消耗过滤函数，筛选风属性手卡怪兽
function c1187243.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable()
end
-- ③效果的消耗处理函数
function c1187243.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足③效果的消耗条件
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c1187243.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将自身从墓地除外作为消耗
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡丢弃1只风属性怪兽作为消耗
	Duel.DiscardHand(tp,c1187243.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- ③效果的检索过滤函数，筛选「薰风」魔法·陷阱卡
function c1187243.thfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③效果的检索目标选择函数
function c1187243.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足③效果的检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c1187243.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置③效果的检索处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的检索处理函数
function c1187243.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择检索目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择检索目标
	local g=Duel.SelectMatchingCard(tp,c1187243.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看检索到的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
