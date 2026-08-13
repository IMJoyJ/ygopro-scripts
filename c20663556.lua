--イレカエル
-- 效果：
-- 把自己场上存在的1只怪兽作为祭品。从自己卡组选择1只名字带有「青蛙」的怪兽在自己场上特殊召唤。只要这张卡在场上存在，名字带有「青蛙」的怪兽不会被战斗破坏。
function c20663556.initial_effect(c)
	-- 把自己场上存在的1只怪兽作为祭品。从自己卡组选择1只名字带有「青蛙」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20663556,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c20663556.cost)
	e1:SetTarget(c20663556.target)
	e1:SetOperation(c20663556.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，名字带有「青蛙」的怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c20663556.indes)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 判断卡片是否属于「青蛙」字段，作为不会被战斗破坏效果的适用对象。
function c20663556.indes(e,c)
	return c:IsSetCard(0x12)
end
-- 筛选可解放的怪兽：如果己方已有空的怪兽区域，则可解放任意怪兽；若没有空位，则只能解放自己主要怪兽区的怪兽，以确保解放后腾出可用的主怪兽区格子。
function c20663556.cfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 支付发动代价：从自己场上选择1只符合条件的怪兽解放（效果发动时的COST处理）。
function c20663556.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上主要怪兽区域的可用空格数，用于判断解放后能否腾出特召位置。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果发动合法性检查：确认当前可用格子数不为-1，且己方场上存在至少1只符合条件的可解放怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c20663556.cfilter,1,nil,ft,tp) end
	-- 由玩家选择1只符合筛选条件的己方场上怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c20663556.cfilter,1,1,nil,ft,tp)
	-- 将所选怪兽以COST方式解放（送去墓地），完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- 筛选自己卡组中满足“名字带有「青蛙」字段”且能够被特殊召唤的怪兽。
function c20663556.filter(c,e,tp)
	return c:IsSetCard(0x12) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标判定：检查卡组中是否存在符合条件的「青蛙」怪兽，若有则设置从卡组特殊召唤1只怪兽的操作信息。
function c20663556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中是否存在至少1只符合筛选条件的「青蛙」怪兽可以特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c20663556.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向连锁系统登记本次效果的处理信息：从卡组特殊召唤1只怪兽（目标卡在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先确认场上空位，再让玩家从卡组选择1只符合条件的「青蛙」怪兽特殊召唤到自己场上。
function c20663556.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方场上是否有可用怪兽区域，若没有空位则效果不处理并结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给予玩家选择提示：“请选择要特殊召唤的卡”，用于构建特殊召唤的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组筛选并选择1只符合条件的「青蛙」怪兽（选择结果存入g）。
	local g=Duel.SelectMatchingCard(tp,c20663556.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上，按通常规则检查召唤条件与苏生限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
