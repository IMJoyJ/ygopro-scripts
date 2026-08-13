--トークン復活祭
-- 效果：
-- 自己场上存在的衍生物全部破坏。把最多有这个效果破坏的衍生物数量的场上存在的卡破坏。
function c52971673.initial_effect(c)
	-- 对应卡片效果原文：“自己场上存在的衍生物全部破坏。把最多有这个效果破坏的衍生物数量的场上存在的卡破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52971673.target)
	e1:SetOperation(c52971673.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器cfilter：判定卡片是否为衍生物（TYPE_TOKEN），用于选出“自己场上存在的衍生物”。
function c52971673.cfilter(c)
	return c:IsType(TYPE_TOKEN)
end
-- 定义过滤器dfilter：判定卡片不是衍生物，用于筛选可被破坏的场上非衍生物卡。
function c52971673.dfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
-- 效果发动前的条件判定：自己场上存在至少1只衍生物，且双方场上有除本卡以外的至少1张非衍生物卡（可作为破坏对象）。
function c52971673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只衍生物，作为效果可发动的条件之一。
	if chk==0 then return Duel.IsExistingMatchingCard(c52971673.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查双方场上是否存在除本卡以外的至少1张非衍生物卡，作为后续破坏对象存在的条件。
		and Duel.IsExistingMatchingCard(c52971673.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取自己场上所有衍生物的集合，用于登记后续将被破坏的卡片。
	local g=Duel.GetMatchingGroup(c52971673.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 将衍生物组及其数量写入连锁的操作信息，标记此次效果包含破坏行为，供其他卡检索或应对。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：先破坏自己场上全部衍生物，若实际破坏数为0则结束；否则在场上选择最多“该破坏数”的卡（除本卡外）破坏，并分为两段处理。
function c52971673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取自己场上全部衍生物的集合，以当前场上实际存在的衍生物为准。
	local g=Duel.GetMatchingGroup(c52971673.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 以效果原因将自己场上的这些衍生物全部破坏，并记录实际破坏数量dt。
	local dt=Duel.Destroy(g,REASON_EFFECT)
	if dt==0 then return end
	-- 获取场上除本卡以外的所有卡，作为后续选择破坏的候选对象（对应“场上存在的卡”）。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if dg:GetCount()>0 then
		-- 中断当前效果处理，使破坏衍生物与后续选择破坏其他卡不在同一时点处理，避免触发时点合并。
		Duel.BreakEffect()
		-- 向操作玩家显示“请选择要破坏的卡”的选择提示，要求进行破坏对象选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,1,dt,nil)
		-- 为被选中的卡片显示“被选为对象”的动画，并记录它们成为本次效果的对象。
		Duel.HintSelection(sg)
		-- 以效果原因破坏所选的卡片，完成效果中“把最多有这个效果破坏的衍生物数量的场上存在的卡破坏”的处理。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
