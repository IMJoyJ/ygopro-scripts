--A・ジェネクス・アクセル
-- 效果：
-- 「次世代」调整＋调整以外的怪兽1只以上
-- ①：1回合1次，丢弃1张手卡，以自己墓地1只4星以下的机械族怪兽为对象才能发动。那只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽攻击力直到回合结束时变成2倍，不能向对方直接攻击，自己结束阶段除外。
function c66165755.initial_effect(c)
	-- 设置同调召唤手续：以「次世代」调整怪兽加1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，丢弃1张手卡，以自己墓地1只4星以下的机械族怪兽为对象才能发动。那只机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66165755,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c66165755.spcost)
	e1:SetTarget(c66165755.sptg)
	e1:SetOperation(c66165755.spop)
	c:RegisterEffect(e1)
end
-- 定义效果①的发动代价（Cost）函数
function c66165755.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查手卡中是否存在除自身以外的可丢弃卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡中丢弃1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤自己墓地中等级4以下且可以特殊召唤的机械族怪兽
function c66165755.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果①的对象选择（Target）函数
function c66165755.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c66165755.spfilter(chkc,e,tp) end
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在满足过滤条件的怪兽
		and Duel.IsExistingTarget(c66165755.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足过滤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66165755.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果①的效果处理（Operation）函数
function c66165755.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，以及自己场上是否有可用的怪兽区域
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not tc:IsRace(RACE_MACHINE) or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 尝试将对象怪兽以表侧表示特殊召唤
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local atk=tc:GetBaseAttack()
		-- 这个效果特殊召唤的怪兽攻击力直到回合结束时变成2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不能向对方直接攻击
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e2)
		-- 自己结束阶段除外。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCondition(c66165755.rmcon)
		e3:SetOperation(c66165755.rmop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e3:SetCountLimit(1)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 定义除外效果的触发条件函数
function c66165755.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义除外效果的处理函数
function c66165755.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该怪兽表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
