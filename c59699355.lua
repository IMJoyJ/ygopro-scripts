--スクラップ・カウンター
-- 效果：
-- 场上守备表示存在的名字带有「废铁」的怪兽被攻击的场合，那次伤害计算时才能发动。被攻击的名字带有「废铁」的怪兽的守备力上升2000，战斗阶段结束时破坏。
function c59699355.initial_effect(c)
	-- 场上守备表示存在的名字带有「废铁」的怪兽被攻击的场合，那次伤害计算时才能发动。被攻击的名字带有「废铁」的怪兽的守备力上升2000，战斗阶段结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c59699355.condition)
	e1:SetOperation(c59699355.activate)
	c:RegisterEffect(e1)
end
-- 检查被攻击的怪兽是否为守备表示的名字带有「废铁」的怪兽
function c59699355.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标
	local d=Duel.GetAttackTarget()
	return d and d:IsDefensePos() and d:IsSetCard(0x24)
end
-- 使被攻击的怪兽守备力上升2000，并注册在战斗阶段结束时将其破坏的效果
function c59699355.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 被攻击的名字带有「废铁」的怪兽的守备力上升2000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		d:RegisterEffect(e1)
		-- 战斗阶段结束时破坏
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetCountLimit(1)
		e2:SetOperation(c59699355.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		d:RegisterEffect(e2)
	end
end
-- 在战斗阶段结束时执行破坏该怪兽的操作
function c59699355.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该怪兽
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
