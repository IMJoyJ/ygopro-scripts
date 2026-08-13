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
-- 发动条件与选定对象的处理：确认触发事件存在，取出召唤/反转召唤成功的怪兽；若处于选择对象的判定阶段，要求该怪兽满足由对方控制、表侧表示、攻击力1000以上、在场且能成为效果对象；满足条件后将其设为对象并登记破坏的操作信息。
function c4206964.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not eg then return false end
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return ep~=tp and tc:IsFaceup() and tc:GetAttack()>=1000 and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将召唤/反转召唤成功的那只怪兽设置为当前连锁的对象（广义对象，供后续效果处理关联使用）。
	Duel.SetTargetCard(eg)
	-- 登记本次连锁的操作信息：效果分类为破坏，确定处理的卡片为对象怪兽，数量为1，用于让系统及关联卡正确识别该效果的破坏性质。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理时：取出召唤/反转召唤成功的怪兽，确认其仍与发动效果关联、表侧表示且攻击力1000以上，满足条件则将其破坏。
function c4206964.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>=1000 then
		-- 以效果原因（REASON_EFFECT）将那只怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
