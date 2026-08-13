--サブマリンロイド
-- 效果：
-- 这张卡可以直接攻击对方玩家。这个时候，给与对方玩家的战斗伤害变成这张卡的原本攻击力的数值。此外，伤害步骤结束时这张卡的表示形式可以变成守备表示。
function c99861526.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这个时候，给与对方玩家的战斗伤害变成这张卡的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c99861526.rdcon)
	e2:SetValue(c99861526.rval)
	c:RegisterEffect(e2)
	-- 此外，伤害步骤结束时这张卡的表示形式可以变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99861526,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c99861526.poscon)
	e3:SetOperation(c99861526.posop)
	c:RegisterEffect(e3)
end
-- 判定直接攻击时改变战斗伤害是否适用的条件：当前攻击目标为空、自身直接攻击效果数量小于2、且对方主要怪兽区存在卡片。
function c99861526.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 当前战斗的攻击目标为空，即这张卡正在对对方玩家进行直接攻击。
	return Duel.GetAttackTarget()==nil
		-- 自身拥有的直接攻击效果数量小于2，且对方主要怪兽区存在卡片，作为直接攻击场合的附加条件。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 若承受战斗伤害的玩家是对方玩家，则将此卡给与的战斗伤害设为原本攻击力；否则返回-1表示不改变。
function c99861526.rval(e,damp)
	if damp==1-e:GetHandlerPlayer() then
		return e:GetHandler():GetBaseAttack()
	else return -1 end
end
-- 触发条件：这张卡仍与本次战斗相关，且处于攻击表示，才能进行表示形式变更。
function c99861526.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsAttackPos()
end
-- 效果处理：若这张卡仍与该效果关联（未离场），则将其变为表侧守备表示。
function c99861526.posop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
	end
end
