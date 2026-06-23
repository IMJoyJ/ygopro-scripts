--聖なるバリア －ミラーフォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
function c44095762.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c44095762.condition)
	e1:SetTarget(c44095762.target)
	e1:SetOperation(c44095762.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为对方的攻击宣言时发动
function c44095762.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前玩家不是回合玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 定义过滤函数，用于筛选攻击表示的怪兽
function c44095762.filter(c)
	return c:IsAttackPos()
end
-- 设置连锁处理的目标，确定要破坏的攻击表示怪兽
function c44095762.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44095762.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c44095762.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，标记将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将符合条件的怪兽全部破坏
function c44095762.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c44095762.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏指定怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
