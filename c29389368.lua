--体力増強剤スーパーZ
-- 效果：
-- ①：自己要受到2000以上的战斗伤害的场合，那次伤害计算时才能发动。自己回复4000基本分。
function c29389368.initial_effect(c)
	-- ①：自己要受到2000以上的战斗伤害的场合，那次伤害计算时才能发动。自己回复4000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c29389368.condition)
	e1:SetTarget(c29389368.target)
	e1:SetOperation(c29389368.activate)
	c:RegisterEffect(e1)
end
-- 发动条件函数：仅在己方将要受到的战斗伤害不低于2000时，该伤害计算时点才满足发动条件。
function c29389368.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中己方将要受到的伤害数值，并判断是否大于等于2000。
	return Duel.GetBattleDamage(tp)>=2000
end
-- 效果发动时的目标处理函数：本效果无需取对象，只要满足发动条件即可发动，并设置操作信息为回复生命值。
function c29389368.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：本效果处理时将让玩家tp回复4000基本分，分类为CATEGORY_RECOVER。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,4000)
end
-- 效果处理函数：在效果结算时执行回复操作。
function c29389368.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家tp回复4000基本分，回复原因标记为REASON_EFFECT（效果回复）。
	Duel.Recover(tp,4000,REASON_EFFECT)
end
