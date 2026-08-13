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
-- 效果发动时的判定与选对象：确认本次召唤/反转召唤成功的怪兽是对方怪兽且为表侧表示、守备力500以下、仍在场上并能成为效果对象；若满足，则将那只怪兽登记为对象，并设置破坏1只怪兽的操作信息。
function c15083728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return ep~=tp and tc:IsFaceup() and tc:GetDefense()<=500 and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将召唤/反转召唤成功的那只怪兽组eg设置为当前效果的对象，使该怪兽与效果建立关联，供后续处理时确认。
	Duel.SetTargetCard(eg)
	-- 登记操作信息：声明本次效果将把tc这1只怪兽破坏（分类为破坏效果），供其他卡牌进行连锁判定或效果响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理阶段：检测之前那只怪兽是否仍表侧表示、是否与该效果仍有联系、守备力是否仍为500以下，全部满足则执行破坏。
function c15083728.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetDefense()<=500 then
		-- 以效果原因（REASON_EFFECT）将那只怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
