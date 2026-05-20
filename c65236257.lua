--創星の因子
-- 效果：
-- ①：选这张卡以外的自己场上的「星骑士」卡数量的场上的魔法·陷阱卡破坏。
function c65236257.initial_effect(c)
	-- ①：选这张卡以外的自己场上的「星骑士」卡数量的场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetTarget(c65236257.target)
	e1:SetOperation(c65236257.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上的魔法·陷阱卡
function c65236257.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤自己场上表侧表示的「星骑士」卡
function c65236257.cfilter(c)
	return c:IsSetCard(0x9c) and c:IsFaceup()
end
-- 效果发动的可行性检测
function c65236257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 计算这张卡以外的自己场上的「星骑士」卡数量
	local ct=Duel.GetMatchingGroupCount(c65236257.cfilter,tp,LOCATION_ONFIELD,0,c)
	if chk==0 then return ct>0
		-- 检查场上是否存在足够数量的、除这张卡以外的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c65236257.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c) end
	-- 获取场上除这张卡以外的所有魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c65236257.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置破坏操作的信息，包含可能被破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果处理的执行函数
function c65236257.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，重新计算这张卡以外的自己场上的「星骑士」卡数量
	local ct=Duel.GetMatchingGroupCount(c65236257.cfilter,tp,LOCATION_ONFIELD,0,c)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择与「星骑士」卡数量相同数量的、除这张卡以外的场上的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c65236257.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,c)
	-- 破坏选中的卡片
	Duel.Destroy(g,REASON_EFFECT)
end
