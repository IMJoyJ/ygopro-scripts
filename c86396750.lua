--精霊獣 アペライオ
-- 效果：
-- 自己对「精灵兽 火狮」1回合只能有1次特殊召唤。
-- ①：自己·对方回合1次，把自己墓地1张「灵兽」卡除外才能发动。这个回合中自己场上的「灵兽」怪兽的攻击力·守备力上升500。
function c86396750.initial_effect(c)
	c:SetSPSummonOnce(86396750)
	-- ①：自己·对方回合1次，把自己墓地1张「灵兽」卡除外才能发动。这个回合中自己场上的「灵兽」怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86396750,0))  --"攻守上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1)
	-- 设置效果的发动条件为不在伤害计算后（限制在伤害步骤中只能在伤害计算前发动）
	e1:SetCondition(aux.dscon)
	e1:SetCost(c86396750.atkcost)
	e1:SetOperation(c86396750.atkop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的「灵兽」卡，且可以作为代价值除外
function c86396750.cfilter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价（Cost）：检查并从自己墓地将1张「灵兽」卡除外
function c86396750.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己墓地是否存在至少1张满足过滤条件的「灵兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86396750.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足过滤条件的「灵兽」卡
	local g=Duel.SelectMatchingCard(tp,c86396750.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理（Operation）：在场上注册使自己场上的「灵兽」怪兽攻击力·守备力上升500的效果，该效果持续到回合结束
function c86396750.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中自己场上的「灵兽」怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c86396750.atktg)
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册攻击力上升的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 向全局环境注册守备力上升的效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果适用对象过滤：自己场上的「灵兽」怪兽
function c86396750.atktg(e,c)
	return c:IsSetCard(0xb5)
end
