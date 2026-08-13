--聖魔 裁きの雷
-- 效果：
-- 这个卡名在规则上也当作「大贤者」卡、「恩底弥翁」卡使用。
-- ①：可以把自己场上1张其他的表侧表示的「大贤者」卡送去墓地或2个魔力指示物取除，从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从自己的手卡·额外卡组（表侧）·墓地把1只魔法师族怪兽特殊召唤。
-- ●场上1张其他卡除外。
local s,id,o=GetID()
-- 初始化效果：注册一个速攻魔法（自由时点发动）的启动效果，效果分类为特殊召唤或除外，并绑定代价、目标与处理函数
function s.initial_effect(c)
	-- ①：可以把自己场上1张其他的表侧表示的「大贤者」卡送去墓地或2个魔力指示物取除，从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。●从自己的手卡·额外卡组（表侧）·墓地把1只魔法师族怪兽特殊召唤。●场上1张其他卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x1]=true,
}
-- 代价可行性的辅助判定：确认场上存在除指定卡以外可以除外的卡，或手卡·额外卡组·墓地存在可特殊召唤的魔法师族怪兽
function s.costcheck(c,ec,e,tp)
	-- 检查双方场上是否存在除这张卡与将被送墓的卡之外可以除外的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
	-- 或者检查自己的手卡·额外卡组（表侧）·墓地是否存在满足特殊召唤条件的魔法师族怪兽
	or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 送墓代价的过滤器：这张卡须为场上表侧表示的「大贤者」卡、可以作为代价送去墓地，且送墓后仍能实现后续效果
function s.tgfilter(c,ec,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x150) and c:IsAbleToGraveAsCost() and s.costcheck(c,ec,e,tp)
end
-- 代价处理：判定两种代价方式是否可行，让玩家选择「取除魔力指示物来发动」或「把卡送墓来发动」，然后执行对应的代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定方式一是否可行：能否作为代价取除自己场上2个魔力指示物，且取除后仍能实现后续效果
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) and s.costcheck(nil,e:GetHandler(),e,tp)
	-- 判定方式二是否可行：自己场上是否存在可以作为代价送去墓地的表侧表示的「大贤者」卡
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandler(),e,tp)
	if chk==0 then return b1 or b2 end
	local cost=0
	if b1 or b2 then
		-- 让玩家从两种代价方式中选择一项
		cost=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"取除魔力指示物来发动"
			{b2,aux.Stringid(id,2),2})  --"把卡送墓来发动"
	end
	if cost==1 then
		-- 作为代价取除自己场上2个魔力指示物
		Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
	elseif cost==2 then
		-- 向玩家提示「请选择要送去墓地的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择自己场上1张作为代价送去墓地的表侧表示的「大贤者」卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e:GetHandler(),e,tp)
		-- 把选择的卡作为代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 特殊召唤对象的过滤器：须为表侧表示的魔法师族怪兽、可以被特殊召唤，且对应来源有足够的可用怪兽区域
function s.spfilter(c,e,tp,rc)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若该卡来自手卡或墓地，则要求考虑送墓代价的卡离场后自己场上仍有可用的主要怪兽区域
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,rc)>0
			-- 若该卡来自额外卡组，则要求考虑送墓代价的卡离场后有能让额外卡组怪兽出场的空格
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0)
end
-- 目标处理：判定两种效果是否可选（受各1回合1次限制），让玩家选择「特殊召唤」或「除外」，并设置相应的效果分类、使用次数标识与操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 辅助判定：仅在选择送墓代价时，确认送墓后场上仍有可除外的卡（供除外效果的代价阶段判定）
	local b0=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandler(),e,tp) and e:IsCostChecked()
	-- 判定特殊召唤效果是否可选：手卡·额外卡组（表侧）·墓地存在可特殊召唤的魔法师族怪兽（或代价处理后存在除外对象）
	local b1=(Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,nil) or b0)
		-- 且特殊召唤效果本回合尚未使用过（代价检查阶段不受此限制）
		and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	-- 判定除外效果是否可选：双方场上存在除这张卡以外可以除外的卡
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 且除外效果本回合尚未使用过（代价检查阶段不受此限制）
		and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从「特殊召唤」与「除外」两种效果中选择一项发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"特殊召唤"
			{b2,aux.Stringid(id,4),2})  --"除外"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 为玩家注册本回合已使用过特殊召唤效果的标识，直到回合结束，实现各1回合1次
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：预计将1只手卡·额外卡组·墓地的怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 为玩家注册本回合已使用过除外效果的标识，直到回合结束，实现各1回合1次
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_REMOVE)
		end
		-- 设置操作信息：预计将场上1张卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
	end
end
-- 效果处理：根据选择的项目，把1只魔法师族怪兽特殊召唤，或把场上1张其他卡除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 向玩家提示「请选择要特殊召唤的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的手卡·额外卡组（表侧）·墓地选择1只可特殊召唤的魔法师族怪兽（附带王家长眠之谷的过滤）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 把选择的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 向玩家提示「请选择要除外的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择双方场上1张除这张卡以外可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 为选择的卡显示被选为对象的动画并记录
			Duel.HintSelection(g)
			-- 把选择的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
