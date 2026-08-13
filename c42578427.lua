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
-- 发动时的目标判定函数：仅在对方召唤/翻转召唤成功且该怪兽表侧表示、攻击力500以下、仍在场上并且能成为效果对象时允许发动；满足后将这只怪兽设为取对象的目标，并登记破坏效果的操作信息。
function c42578427.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return ep~=tp and tc:IsFaceup() and tc:GetAttack()<=500 and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将当前触发连携的召唤/翻转召唤的怪兽（eg中的怪兽）设为该效果的对象，完成取对象操作。
	Duel.SetTargetCard(eg)
	-- 登记本次连锁的破坏操作信息：预定破坏对象为tc、数量为1，用于后续系统检测（如星尘龙等对破坏的响应）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理时的执行函数：检索当时召唤成功的那只怪兽，确认其仍在场上、表侧表示、与本次效果相关联并且攻击力仍不高于500后，才对其进行破坏。
function c42578427.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()<=500 then
		-- 以效果（REASON_EFFECT）为理由将tc破坏，执行实际破坏动作。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
