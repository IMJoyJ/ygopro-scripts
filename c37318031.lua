--R－ライトジャスティス
-- 效果：
-- ①：选自己场上的「元素英雄」卡数量的场上的魔法·陷阱卡破坏。
function c37318031.initial_effect(c)
	-- ①：选自己场上的「元素英雄」卡数量的场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37318031.target)
	e1:SetOperation(c37318031.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回满足条件的魔法·陷阱卡
function c37318031.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数，返回满足条件的表侧表示的「元素英雄」卡
function c37318031.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果发动时的处理函数，用于判断是否可以发动效果并设置破坏数量
function c37318031.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 统计自己场上的「元素英雄」卡数量
		local ct=Duel.GetMatchingGroupCount(c37318031.cfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		-- 检查自己场上是否存在满足条件的魔法·陷阱卡
		return Duel.IsExistingMatchingCard(c37318031.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c)
	end
	local ct=e:GetLabel()
	-- 获取满足条件的魔法·陷阱卡组
	local sg=Duel.GetMatchingGroup(c37318031.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
end
-- 效果发动时的处理函数，用于执行破坏效果
function c37318031.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上的「元素英雄」卡数量
	local ct=Duel.GetMatchingGroupCount(c37318031.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c37318031.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>=ct then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,ct,ct,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(sg)
		-- 将选中的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
