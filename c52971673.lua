--トークン復活祭
-- 效果：
-- 自己场上存在的衍生物全部破坏。把最多有这个效果破坏的衍生物数量的场上存在的卡破坏。
function c52971673.initial_effect(c)
	-- 效果发动时的初始化设置，包括破坏效果分类、魔陷发动类型、自由连锁时点、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52971673.target)
	e1:SetOperation(c52971673.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡是否为衍生物
function c52971673.cfilter(c)
	return c:IsType(TYPE_TOKEN)
end
-- 过滤函数，用于判断卡是否不为衍生物
function c52971673.dfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
-- 效果发动时的条件检查，确认自己场上存在衍生物且场上存在非衍生物的卡
function c52971673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少一张衍生物
	if chk==0 then return Duel.IsExistingMatchingCard(c52971673.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少一张非衍生物的卡
		and Duel.IsExistingMatchingCard(c52971673.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取自己场上所有衍生物组成卡片组
	local g=Duel.GetMatchingGroup(c52971673.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置效果处理信息，确定要破坏的衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，先破坏场上所有衍生物，再选择最多相同数量的场上卡进行破坏
function c52971673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有衍生物组成卡片组
	local g=Duel.GetMatchingGroup(c52971673.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 将场上所有衍生物破坏，返回实际被破坏的数量
	local dt=Duel.Destroy(g,REASON_EFFECT)
	if dt==0 then return end
	-- 获取场上所有非此卡的卡组成卡片组
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if dg:GetCount()>0 then
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,1,dt,nil)
		-- 显示所选卡作为对象的动画效果
		Duel.HintSelection(sg)
		-- 将选定的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
