--落とし穴
-- 效果：
-- ①：对方对攻击力1000以上的怪兽的召唤·反转召唤成功时，以那1只怪兽为对象才能发动。那只攻击力1000以上的怪兽破坏。
function c4206964.initial_effect(c)
	-- ①：对方对攻击力1000以上的怪兽的召唤·反转召唤成功时，以那1只怪兽为对象才能发动。那只攻击力1000以上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c4206964.target)
	e1:SetOperation(c4206964.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件，包括对方召唤成功、怪兽表侧表示、攻击力不低于1000、在场且可成为效果对象
function c4206964.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not eg then return false end
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return ep~=tp and tc:IsFaceup() and tc:GetAttack()>=1000 and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将当前连锁处理的对象设置为满足条件的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息，表明此效果属于破坏类别，目标为1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行效果处理，若怪兽满足条件则将其破坏
function c4206964.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>=1000 then
		-- 以效果为原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
