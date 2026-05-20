--サイファー・スカウター
-- 效果：
-- 这张卡和战士族怪兽进行战斗的伤害计算时发动。这张卡的攻击力·守备力只在那次伤害计算时上升2000。
function c79853073.initial_effect(c)
	-- 这张卡和战士族怪兽进行战斗的伤害计算时发动。这张卡的攻击力·守备力只在那次伤害计算时上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79853073,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c79853073.con)
	e1:SetOperation(c79853073.op)
	c:RegisterEffect(e1)
end
-- 检查与自身进行战斗的怪兽是否存在且是否为战士族怪兽，作为效果的发动条件
function c79853073.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsRace(RACE_WARRIOR)
end
-- 若自身仍表侧表示存在，则在伤害计算时使自身的攻击力与守备力上升2000
function c79853073.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力……只在那次伤害计算时上升2000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(2000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
