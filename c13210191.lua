--嵐
-- 效果：
-- 自己场上的魔法·陷阱卡全部破坏。那之后，把破坏的卡数量的对方场上的魔法·陷阱卡破坏。
function c13210191.initial_effect(c)
	-- 卡片效果：自己场上的魔法·陷阱卡全部破坏。那之后，把破坏的卡数量的对方场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c13210191.target)
	e1:SetOperation(c13210191.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡是否为魔法或陷阱类型
function c13210191.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的target函数，用于设置效果的处理目标
function c13210191.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件，即自己场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13210191.filter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 获取自己场上的魔法·陷阱卡组
	local g1=Duel.GetMatchingGroup(c13210191.filter,tp,LOCATION_ONFIELD,0,c)
	-- 获取对方场上的魔法·陷阱卡组
	local g2=Duel.GetMatchingGroup(c13210191.filter,tp,0,LOCATION_ONFIELD,nil)
	local ct1=g1:GetCount()
	local ct2=g2:GetCount()
	g1:Merge(g2)
	-- 设置连锁操作信息，确定要破坏的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,ct1+((ct1>ct2) and ct2 or ct1),0,0)
end
-- 效果的activate函数，用于执行效果的处理流程
function c13210191.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的魔法·陷阱卡组（排除此卡）
	local g1=Duel.GetMatchingGroup(c13210191.filter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 将自己场上的魔法·陷阱卡全部破坏，并返回实际破坏数量
	local ct1=Duel.Destroy(g1,REASON_EFFECT)
	if ct1==0 then return end
	-- 获取对方场上的魔法·陷阱卡组
	local g2=Duel.GetMatchingGroup(c13210191.filter,tp,0,LOCATION_ONFIELD,nil)
	local ct2=g2:GetCount()
	if ct2==0 then return end
	-- 中断当前效果处理，使后续效果视为不同时处理
	Duel.BreakEffect()
	if ct2<=ct1 then
		-- 将对方场上的所有魔法·陷阱卡全部破坏
		Duel.Destroy(g2,REASON_EFFECT)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g3=g2:Select(tp,ct1,ct1,nil)
		-- 显示所选卡被选为对象的动画效果
		Duel.HintSelection(g3)
		-- 将所选的卡破坏
		Duel.Destroy(g3,REASON_EFFECT)
	end
end
