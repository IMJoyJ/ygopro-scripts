--トークン復活祭
-- 效果：
-- 自己场上存在的衍生物全部破坏。把最多有这个效果破坏的衍生物数量的场上存在的卡破坏。
function c52971673.initial_effect(c)
	-- 自己场上存在的衍生物全部破坏。把最多有这个效果破坏的衍生物数量的场上存在的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52971673.target)
	e1:SetOperation(c52971673.activate)
	c:RegisterEffect(e1)
end
-- 过滤衍生物
function c52971673.cfilter(c)
	return c:IsType(TYPE_TOKEN)
end
-- 过滤非衍生物卡片
function c52971673.dfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
-- 发动目标：自己场上存在衍生物且场上存在自身以外的非衍生物卡片
function c52971673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在衍生物
	if chk==0 then return Duel.IsExistingMatchingCard(c52971673.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断场上是否存在自身以外的非衍生物卡片
		and Duel.IsExistingMatchingCard(c52971673.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取自己场上所有的衍生物
	local g=Duel.GetMatchingGroup(c52971673.cfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置操作信息：破坏自己场上的全部衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏自己场上全部衍生物，选最多有破坏数量的场上的卡破坏
function c52971673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的衍生物
	local g=Duel.GetMatchingGroup(c52971673.cfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 破坏自己场上的衍生物并记录破坏数量
	local dt=Duel.Destroy(g,REASON_EFFECT)
	if dt==0 then return end
	-- 获取场上自身以外的所有卡
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if dg:GetCount()>0 then
		-- 中断当前效果，使之后的破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,1,dt,nil)
		-- 显示选中的卡片被选为破坏对象
		Duel.HintSelection(sg)
		-- 破坏选中的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
