--D－カウンター
-- 效果：
-- 自己场上表侧表示存在的名字带有「命运英雄」的怪兽被选择作为攻击对象时才能发动。攻击怪兽破坏。
function c8698851.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「命运英雄」的怪兽被选择作为攻击对象时才能发动。攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c8698851.condition)
	e1:SetTarget(c8698851.target)
	e1:SetOperation(c8698851.operation)
	c:RegisterEffect(e1)
end
-- 检查被选择作为攻击对象的怪兽是否为自己场上表侧表示的「命运英雄」怪兽
function c8698851.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsPosition(POS_FACEUP) and tc:IsSetCard(0xc008)
end
-- 确认攻击怪兽存在，将其设为效果处理的对象，并设置破坏该怪兽的操作信息
function c8698851.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	if chk==0 then return a:IsOnField() end
	-- 将攻击怪兽设为当前连锁的处理对象
	Duel.SetTargetCard(a)
	-- 设置效果处理信息，表示该连锁将破坏1张作为对象的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
end
-- 在效果处理时，若作为对象的怪兽仍符合条件，则将其破坏
function c8698851.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
