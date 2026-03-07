--グリフォンの羽根帚
-- 效果：
-- 破坏自己场上所有魔法·陷阱卡。自己回复被破坏的卡数量×500基本分。
function c34370473.initial_effect(c)
	-- 效果原文内容：破坏自己场上所有魔法·陷阱卡。自己回复被破坏的卡数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34370473.target)
	e1:SetOperation(c34370473.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤函数，用于筛选场上魔法·陷阱卡。
function c34370473.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：设置连锁处理时的条件判断与操作信息，包括破坏和回复效果。
function c34370473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果作用：判断是否满足发动条件，即自己场上是否存在魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c34370473.filter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 效果作用：获取自己场上所有魔法·陷阱卡组成的组。
	local g=Duel.GetMatchingGroup(c34370473.filter,tp,LOCATION_ONFIELD,0,c)
	-- 效果作用：设置破坏效果的操作信息，指定要破坏的卡组及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 效果作用：设置回复效果的操作信息，指定回复的LP数量。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*500)
end
-- 效果作用：执行效果的处理函数，实现破坏与回复操作。
function c34370473.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取自己场上所有魔法·陷阱卡组成的组（排除此卡自身）。
	local g=Duel.GetMatchingGroup(c34370473.filter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 效果作用：将指定卡组全部破坏，返回实际破坏的卡数。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 效果作用：根据破坏卡数回复相应基本分。
	Duel.Recover(tp,ct*500,REASON_EFFECT)
end
