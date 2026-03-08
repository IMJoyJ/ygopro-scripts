--ねずみ取り
-- 效果：
-- 对方召唤·反转召唤的怪兽的攻击力在500以下的场合，可以把那1只怪兽破坏。
function c42578427.initial_effect(c)
	-- 对方召唤·反转召唤的怪兽的攻击力在500以下的场合，可以把那1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42578427.target)
	e1:SetOperation(c42578427.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果处理时，检查目标怪兽是否满足条件（对方召唤/反转召唤、表侧表示、攻击力≤500、在场、可成为效果对象）
function c42578427.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return ep~=tp and tc:IsFaceup() and tc:GetAttack()<=500 and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将当前连锁处理的目标设置为发动时的怪兽组
	Duel.SetTargetCard(eg)
	-- 设置操作信息，指定本次效果属于破坏类别，目标为1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果发动时，确认目标怪兽满足条件后执行破坏操作
function c42578427.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()<=500 then
		-- 以效果原因将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
