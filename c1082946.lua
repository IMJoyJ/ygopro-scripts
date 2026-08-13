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
-- 过滤函数：检查卡片是否带有卡号1082946的标记（即是否是该效果处理过的回合计数卡）。
function c1082946.filter(c)
	return c:GetFlagEffect(1082946)~=0
end
-- 发动时的目标函数：仅在效果发动合法性检查阶段，判断场上是否存在至少1张带有1082946标记的卡。
function c1082946.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动合法性检查（chk==0），则返回是否存在满足过滤条件的卡，以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c1082946.filter,tp,0x3f,0x3f,1,nil) end
end
-- 效果处理函数：从带有1082946标记的卡中选择1张，对该卡的回合计数效果执行一次操作，使其回合计算前进1回合。
function c1082946.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，告知玩家“请选择要让回合计数前进的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1082946,0))  --"请选择要让回合计数前进的卡"
	-- 让玩家从所有带有1082946标记的卡中选取1张（双方场上、墓地、除外等全部区域）。
	local g=Duel.SelectMatchingCard(tp,c1082946.filter,tp,0x3f,0x3f,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	local turne=tc[tc]
	local op=turne:GetOperation()
	op(turne,turne:GetOwnerPlayer(),nil,0,0,0,0,0)
end
