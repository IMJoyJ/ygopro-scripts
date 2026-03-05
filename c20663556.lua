--イレカエル
-- 效果：
-- 把自己场上存在的1只怪兽作为祭品。从自己卡组选择1只名字带有「青蛙」的怪兽在自己场上特殊召唤。只要这张卡在场上存在，名字带有「青蛙」的怪兽不会被战斗破坏。
function c20663556.initial_effect(c)
	-- 效果原文：把自己场上存在的1只怪兽作为祭品。从自己卡组选择1只名字带有「青蛙」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20663556,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c20663556.cost)
	e1:SetTarget(c20663556.target)
	e1:SetOperation(c20663556.operation)
	c:RegisterEffect(e1)
	-- 效果原文：只要这张卡在场上存在，名字带有「青蛙」的怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c20663556.indes)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否为青蛙族
function c20663556.indes(e,c)
	return c:IsSetCard(0x12)
end
-- 判断是否可以解放怪兽作为祭品
function c20663556.cfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 支付效果的解放祭品费用，从场上选择1只怪兽进行解放
function c20663556.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足支付解放祭品的条件
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c20663556.cfilter,1,nil,ft,tp) end
	-- 选择满足条件的怪兽作为祭品进行解放
	local g=Duel.SelectReleaseGroup(tp,c20663556.cfilter,1,1,nil,ft,tp)
	-- 实际执行怪兽的解放操作
	Duel.Release(g,REASON_COST)
end
-- 筛选卡组中名字带有青蛙族的怪兽
function c20663556.filter(c,e,tp)
	return c:IsSetCard(0x12) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理信息，确定将要特殊召唤的怪兽
function c20663556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的青蛙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c20663556.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行效果的处理程序，从卡组选择青蛙族怪兽并特殊召唤
function c20663556.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的青蛙族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只青蛙族怪兽作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c20663556.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的青蛙族怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
