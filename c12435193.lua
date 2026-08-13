--コアキメイル・ドラゴ
-- 效果：
-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只龙族怪兽给对方观看。或者都不进行让这张卡破坏。
-- ①：只要这张卡在怪兽区域存在，双方不能把光·暗属性怪兽特殊召唤。
function c12435193.initial_effect(c)
	-- 记录这张卡上记载着「核成兽的钢核」的卡名，用于关联相关卡片文本/效果。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只龙族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12435193.mtcon)
	e1:SetOperation(c12435193.mtop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，双方不能把光·暗属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c12435193.disspsum)
	c:RegisterEffect(e2)
end
-- 效果发动条件：仅在当前回合玩家为这张卡的控制者（即控制者的结束阶段）时，维持代价效果才适用。
function c12435193.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者tp，是则返回true。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为维持cost的「核成兽的钢核」：卡名正确且可以作为代价送去墓地。
function c12435193.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中可供对方观看的龙族怪兽：必须是怪兽卡、龙族且当前不是公开状态。
function c12435193.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
-- 结束阶段执行维持cost：根据手卡情况让控制者选择送「核成兽的钢核」去墓地、展示手卡龙族怪兽，或都不进行则破坏「核成龙」。
function c12435193.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动为「核成龙」显示被选为对象的动画，并将其记为被选择的对象。
	Duel.HintSelection(Group.FromCards(c))
	-- 取得控制者手卡中所有可以作为代价送去墓地的「核成兽的钢核」的集合。
	local g1=Duel.GetMatchingGroup(c12435193.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 取得控制者手卡中所有可供对方观看的龙族怪兽（非公开状态）的集合。
	local g2=Duel.GetMatchingGroup(c12435193.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 手卡中两种维持手段都存在时，弹出三项选择：送钢核去墓地／展示龙族怪兽／破坏核成龙。
		select=Duel.SelectOption(tp,aux.Stringid(12435193,0),aux.Stringid(12435193,1),aux.Stringid(12435193,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只龙族怪物给对方观看/破坏「核成龙」"
	elseif g1:GetCount()>0 then
		-- 只有钢核可送时，弹出两项选择：送钢核去墓地／破坏核成龙，若选破坏则将select修正为2。
		select=Duel.SelectOption(tp,aux.Stringid(12435193,0),aux.Stringid(12435193,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成龙」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 只有龙族怪兽可展示时，弹出两项选择：展示龙族怪兽／破坏核成龙，+1后使后续分支正确对应。
		select=Duel.SelectOption(tp,aux.Stringid(12435193,1),aux.Stringid(12435193,2))+1  --"选择一只龙族怪物给对方观看/破坏「核成龙」"
	else
		-- 两种维持手段都没有时，强制选择破坏核成龙，select设为2。
		select=Duel.SelectOption(tp,aux.Stringid(12435193,2))  --"破坏「核成龙」"
		select=2
	end
	if select==0 then
		-- 进入送墓分支时，提示控制者选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的「核成兽的钢核」作为维持cost送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 进入展示分支时，提示控制者选择要给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选择的龙族怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切控制者的手卡，清除公开状态造成的信息残留。
		Duel.ShuffleHand(tp)
	else
		-- 没有执行送墓或展示的维持行为，将「核成龙」自身破坏作为不维持的代价。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判定要特殊召唤的怪兽是否属于光属性或暗属性；若是则被「核成龙」的①效果禁止特殊召唤。
function c12435193.disspsum(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT)
end
