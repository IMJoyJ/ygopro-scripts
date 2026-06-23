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
-- 检查玩家在本次战斗中受到的伤害是否大于等于2000
function c29389368.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己要受到2000以上的战斗伤害的场合
	return Duel.GetBattleDamage(tp)>=2000
end
-- 设置效果发动时的处理信息，确定将要回复4000基本分
function c29389368.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要回复4000基本分的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,4000)
end
-- 发动效果，使自己回复4000基本分
function c29389368.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 自己回复4000基本分
	Duel.Recover(tp,4000,REASON_EFFECT)
end
