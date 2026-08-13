--コアキメイル・ビートル
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只昆虫族怪兽给对方观看。或者都不进行让这张卡破坏。光属性或者暗属性怪兽表侧攻击表示特殊召唤成功时，那些怪兽变成守备表示。
function c39037517.initial_effect(c)
	-- 将「核成兽的钢核」（36623431）登记进本卡的关联卡名列表，使系统识别这张卡卡名中记载了「核成兽的钢核」。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只昆虫族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c39037517.mtcon)
	e1:SetOperation(c39037517.mtop)
	c:RegisterEffect(e1)
	-- 光属性或者暗属性怪兽表侧攻击表示特殊召唤成功时，那些怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39037517,3))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c39037517.target)
	e2:SetOperation(c39037517.operation)
	c:RegisterEffect(e2)
end
-- 定义维持费用的触发条件：仅当当前回合玩家是这张卡的控制者时，才在自己的结束阶段执行维持处理。
function c39037517.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，用于确认是否处于这张卡的控制者的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤出控制者手卡中可作代价送去墓地的「核成兽的钢核」卡片。
function c39037517.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤出控制者手卡中可给对方观看的昆虫族怪兽（且该卡尚未公开）。
function c39037517.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_INSECT) and not c:IsPublic()
end
-- 执行维持费用的处理：让控制者在自己的结束阶段选择从手卡送1张「核成兽的钢核」去墓地、展示1张手卡昆虫族怪兽，若不进行则破坏这张卡；根据手牌情况弹出对应选项并执行。
function c39037517.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将该卡本身展示并标记为当前处理对象，向玩家提示正在处理这张卡的结束阶段维持效果。
	Duel.HintSelection(Group.FromCards(c))
	-- 取得控制者手卡中所有满足条件的「核成兽的钢核」，作为可送墓的候选。
	local g1=Duel.GetMatchingGroup(c39037517.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 取得控制者手卡中所有可展示的昆虫族怪兽，作为可展示的候选。
	local g2=Duel.GetMatchingGroup(c39037517.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当两种维持方式均有可选卡时，让控制者三选一：送去1张「核成兽的钢核」、展示1张昆虫族怪兽、或直接破坏此卡。
		select=Duel.SelectOption(tp,aux.Stringid(39037517,0),aux.Stringid(39037517,1),aux.Stringid(39037517,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张昆虫族怪兽给对方观看/破坏「核成甲虫」"
	elseif g1:GetCount()>0 then
		-- 当只有「核成兽的钢核」可送时，让控制者二选一：送墓钢核或直接破坏此卡。
		select=Duel.SelectOption(tp,aux.Stringid(39037517,0),aux.Stringid(39037517,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成甲虫」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当只有昆虫族怪兽可展示时，让控制者二选一：展示昆虫怪兽或直接破坏此卡。
		select=Duel.SelectOption(tp,aux.Stringid(39037517,1),aux.Stringid(39037517,2))+1  --"选择一张昆虫族怪兽给对方观看/破坏「核成甲虫」"
	else
		-- 当两种维持方式都无卡可选时，只能选择破坏此卡（将选项结果设为破坏）。
		select=Duel.SelectOption(tp,aux.Stringid(39037517,2))  --"破坏「核成甲虫」"
		select=2
	end
	if select==0 then
		-- 在选择送墓的卡片前，向控制者显示“请选择要送去墓地的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将控制者选择的「核成兽的钢核」从手牌作为维持代价送入墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 在选择展示的手卡怪兽前，向控制者显示“请选择给对方确认的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将控制者选择的手卡昆虫族怪兽给对方玩家确认，完成“给对方观看”的动作。
		Duel.ConfirmCards(1-tp,g)
		-- 展示手牌后洗切控制者的手牌，避免对方通过卡片顺序获取额外信息。
		Duel.ShuffleHand(tp)
	else
		-- 因控制者未选择任何维持方式，以维持失败为代价将这张卡「核成甲虫」破坏。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 定义筛选条件：怪兽须为表侧攻击表示，且属性为光属性或暗属性；若传入效果e，还须与该效果存在关联（即仍在效果处理对象中）。
function c39037517.filter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and (not e or c:IsRelateToEffect(e))
end
-- 特殊召唤成功时检查是否存在符合条件的怪兽；若存在，则将本次特殊召唤成功的怪兽全部登记为对象，以供后续改变表示形式。
function c39037517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c39037517.filter,1,nil) end
	-- 将本次特殊召唤成功的所有怪兽设置为当前效果的处理对象，使这些怪兽与效果建立联系，保证效果处理时能正确追踪。
	Duel.SetTargetCard(eg)
end
-- 效果处理时，从已登记对象中筛选出仍满足表侧攻击表示、光/暗属性且与效果相关的怪兽，并将它们全部变为表侧守备表示。
function c39037517.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c39037517.filter,nil,e)
	-- 将筛选出的怪兽的表示形式统一改为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
