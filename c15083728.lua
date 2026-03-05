--粘着テープの家
-- 效果：
-- 对方把守备力500以下的怪兽召唤·反转召唤时才能发动。那1只怪兽破坏。
function c15083728.initial_effect(c)
	-- 对方把守备力500以下的怪兽召唤·反转召唤时才能发动。那1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c15083728.target)
	e1:SetOperation(c15083728.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件，包括对方召唤、怪兽表侧表示、守备力不超过500、在场且可成为效果对象
function c15083728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return ep~=tp and tc:IsFaceup() and tc:GetDefense()<=500 and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将当前连锁的目标设置为召唤成功的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息，表明此效果属于破坏类别，目标为1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行效果处理，若目标怪兽满足条件则将其破坏
function c15083728.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetDefense()<=500 then
		-- 以效果为原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
