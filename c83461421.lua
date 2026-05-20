--ペンデュラム・ストーム
-- 效果：
-- ①：双方的灵摆区域的卡全部破坏。那之后，可以选对方场上1张魔法·陷阱卡破坏。
function c83461421.initial_effect(c)
	-- ①：双方的灵摆区域的卡全部破坏。那之后，可以选对方场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83461421.target)
	e1:SetOperation(c83461421.activate)
	c:RegisterEffect(e1)
end
-- 过滤魔法·陷阱卡的条件函数
function c83461421.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标确认与操作信息设置
function c83461421.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件，检查双方灵摆区域是否有卡存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,LOCATION_PZONE)>0 end
	-- 获取双方灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 设置破坏操作信息，包含要破坏的灵摆区域卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数
function c83461421.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 破坏双方灵摆区域的所有卡，并判断是否有卡被成功破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取对方场上所有的魔法·陷阱卡
		local dg=Duel.GetMatchingGroup(c83461421.filter2,tp,0,LOCATION_ONFIELD,nil)
		-- 若对方场上有魔法·陷阱卡，则询问玩家是否选择进行破坏
		if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(83461421,0)) then  --"是否选对方场上1张魔法·陷阱卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理与前面的破坏不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,1,nil)
			-- 向双方玩家展示所选择的卡
			Duel.HintSelection(sg)
			-- 破坏选中的对方场上的魔法·陷阱卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
