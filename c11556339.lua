--霊獣の連契
-- 效果：
-- ①：把最多有自己场上的「灵兽」怪兽数量的场上的怪兽破坏。
function c11556339.initial_effect(c)
	-- 效果原文内容：①：把最多有自己场上的「灵兽」怪兽数量的场上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c11556339.condition)
	e1:SetTarget(c11556339.target)
	e1:SetOperation(c11556339.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为表侧表示的灵兽族怪兽
function c11556339.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb5)
end
-- 效果条件函数，判断自己场上是否存在灵兽族怪兽
function c11556339.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只灵兽族怪兽
	return Duel.IsExistingMatchingCard(c11556339.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的处理函数，用于设置发动时的处理目标
function c11556339.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取自己场上所有怪兽的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁处理信息，指定将要破坏的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理函数，用于执行效果的破坏处理
function c11556339.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上灵兽族怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c11556339.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 向玩家提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择最多等于灵兽族怪兽数量的怪兽作为破坏对象
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	if g:GetCount()>0 then
		-- 显示被选为对象的怪兽动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽以效果原因进行破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
