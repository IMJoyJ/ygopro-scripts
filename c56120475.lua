--炸裂装甲
-- 效果：
-- ①：对方怪兽的攻击宣言时，以1只攻击怪兽为对象才能发动。那只攻击怪兽破坏。
function c56120475.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以1只攻击怪兽为对象才能发动。那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c56120475.condition)
	e1:SetTarget(c56120475.target)
	e1:SetOperation(c56120475.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件
function c56120475.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即对方怪兽宣言攻击）
	return tp~=Duel.GetTurnPlayer()
end
-- 定义效果的对象选择与操作信息
function c56120475.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果的对象
	Duel.SetTargetCard(tg)
	-- 设置效果的操作信息为破坏该攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 定义效果的处理逻辑
function c56120475.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 因效果将该怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
