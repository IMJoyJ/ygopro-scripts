--運命の火時計
-- 效果：
-- 1张卡的回合计算前进1回合。
function c1082946.initial_effect(c)
	-- 1张卡的回合计算前进1回合。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1082946.target)
	e1:SetOperation(c1082946.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否存在带有标识效果1082946的卡
function c1082946.filter(c)
	return c:GetFlagEffect(1082946)~=0
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c1082946.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的卡（即带有标识效果1082946的卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c1082946.filter,tp,0x3f,0x3f,1,nil) end
end
-- 效果发动时的处理函数，用于执行效果
function c1082946.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要让回合计数前进的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1082946,0))  --"请选择要让回合计数前进的卡"
	-- 选择满足条件的1张卡作为目标
	local g=Duel.SelectMatchingCard(tp,c1082946.filter,tp,0x3f,0x3f,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	local turne=tc[tc]
	local op=turne:GetOperation()
	op(turne,turne:GetOwnerPlayer(),nil,0,0,0,0,0)
end
