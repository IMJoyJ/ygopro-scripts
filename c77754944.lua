--万能地雷グレイモヤ
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的表侧攻击表示怪兽之内攻击力最高的1只怪兽破坏。
function c77754944.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的表侧攻击表示怪兽之内攻击力最高的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c77754944.condition)
	e1:SetTarget(c77754944.target)
	e1:SetOperation(c77754944.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件
function c77754944.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：表侧表示且为攻击表示的怪兽
function c77754944.filter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 定义效果的发动准备（Target）阶段
function c77754944.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：对方场上是否存在至少1只表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77754944.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c77754944.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 设置效果处理信息：破坏攻击力最高的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 定义效果处理（Operation）阶段
function c77754944.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c77754944.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 破坏玩家选择的攻击力最高的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若攻击力最高的怪兽只有1只，则直接将其破坏
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
