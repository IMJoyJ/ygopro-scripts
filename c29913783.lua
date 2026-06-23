--対壊獣用決戦兵器メカサンダー・キング
-- 效果：
-- 这个卡名的④的效果在决斗中只能使用1次。
-- ①：双方的主要阶段把这张卡从手卡丢弃才能发动。选原本持有者是对方的自己场上1只「坏兽」怪兽除外。那之后，可以从自己墓地选1只怪兽特殊召唤。
-- ②：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ③：场上的这张卡不受其他的「坏兽」卡的效果影响，不会被和「坏兽」怪兽的战斗破坏。
-- ④：自己结束阶段才能发动。这张卡从墓地特殊召唤。
function c29913783.initial_effect(c)
	-- 设置此卡在场上的唯一性，确保同一回合内场上只能存在一只属于坏兽族的卡
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：双方的主要阶段把这张卡从手卡丢弃才能发动。选原本持有者是对方的自己场上1只「坏兽」怪兽除外。那之后，可以从自己墓地选1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29913783,0))  --"除外坏兽并苏生"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c29913783.spcon)
	e1:SetCost(c29913783.spcost)
	e1:SetTarget(c29913783.sptg)
	e1:SetOperation(c29913783.spop)
	c:RegisterEffect(e1)
	-- ③：场上的这张卡不受其他的「坏兽」卡的效果影响，不会被和「坏兽」怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c29913783.indval)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡不受其他的「坏兽」卡的效果影响，不会被和「坏兽」怪兽的战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c29913783.efilter)
	c:RegisterEffect(e3)
	-- ④：自己结束阶段才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29913783,1))  --"这张卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,29913783+EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(c29913783.spcon2)
	e4:SetTarget(c29913783.sptg2)
	e4:SetOperation(c29913783.spop2)
	c:RegisterEffect(e4)
end
-- 效果发动条件：当前阶段为准备阶段或主要阶段
function c29913783.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为准备阶段或主要阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果支付费用：将此卡从手牌丢弃至墓地
function c29913783.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手牌丢弃至墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 除外怪兽的过滤条件：场上表侧表示的坏兽族怪兽，且为对方所有
function c29913783.rmfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd3) and c:IsAbleToRemove() and c:GetOwner()==1-tp
end
-- 设置效果目标：选择场上1只对方的坏兽族怪兽除外
function c29913783.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c29913783.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 设置操作信息：将要除外的怪兽设为操作目标
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
-- 特殊召唤怪兽的过滤条件：可以特殊召唤的怪兽
function c29913783.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果处理：选择除外怪兽并从墓地特殊召唤怪兽
function c29913783.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只对方的坏兽族怪兽除外
	local g=Duel.SelectMatchingCard(tp,c29913783.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 成功除外怪兽后继续处理
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		-- 检查墓地中是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c29913783.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查场上是否有特殊召唤的空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否从墓地特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(29913783,2)) then  --"是否从墓地特殊召唤？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地中1只可特殊召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29913783.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果值：此卡为坏兽族怪兽时免疫战斗破坏
function c29913783.indval(e,c)
	return c:IsSetCard(0xd3)
end
-- 效果值：此卡免疫坏兽族卡的效果
function c29913783.efilter(e,te)
	return te:GetHandler():IsSetCard(0xd3)
end
-- 效果发动条件：当前回合玩家为发动者
function c29913783.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为发动者
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果目标：将此卡特殊召唤到场上
function c29913783.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：将要特殊召唤的卡设为操作目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡从墓地特殊召唤到场上
function c29913783.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
