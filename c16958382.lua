--Sin パラダイム・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。场上没有「罪 范式龙」存在的场合，从额外卡组把1只「罪」怪兽除外的场合才能特殊召唤。
-- ①：场上没有「罪 世界」存在的场合这张卡破坏。
-- ②：1回合1次，从卡组把1张「罪」卡送去墓地才能发动。除外的1只自己的8星同调怪兽回到额外卡组。那之后，可以把那只怪兽从额外卡组特殊召唤。这个回合，自己不用「罪」怪兽不能攻击。
function c16958382.initial_effect(c)
	-- 注册这张卡的效果文本中提及的「罪 世界」（卡号27564031），使相关卡名判定能够正确识别。
	aux.AddCodeList(c,27564031)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 场上没有「罪 范式龙」存在的场合，从额外卡组把1只「罪」怪兽除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16958382.spcon)
	e1:SetTarget(c16958382.sptg)
	e1:SetOperation(c16958382.spop)
	c:RegisterEffect(e1)
	-- ①：场上没有「罪 世界」存在的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c16958382.descon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从卡组把1张「罪」卡送去墓地才能发动。除外的1只自己的8星同调怪兽回到额外卡组。那之后，可以把那只怪兽从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16958382,0))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c16958382.cost)
	e3:SetTarget(c16958382.target)
	e3:SetOperation(c16958382.operation)
	c:RegisterEffect(e3)
end
-- 筛选额外卡组中可以作为特殊召唤手续代价除外的「罪」系列怪兽。
function c16958382.spfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToRemoveAsCost()
end
-- 筛选场上·墓地中持有48829461号效果、可作为代价除外，且除外后不会导致无怪兽区的卡，作为特殊召唤手续的替代素材。
function c16958382.spfilter2(c,tp)
	-- 判断该卡是否持有48829461号效果、可作为代价除外，并确保除外后自己场上仍留有可用怪兽区。
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选双方场上表侧表示存在的同名卡「罪 范式龙」（卡号16958382），用于检查是否已有同名卡在场。
function c16958382.codefilter(c)
	return c:IsCode(16958382) and c:IsFaceup()
end
-- 特殊召唤条件：自己有怪兽区可用的前提下，额外卡组存在可除外的「罪」怪兽，或场上·墓地存在可替代除外的素材；并且双方场上没有表侧表示的另一张「罪 范式龙」。
function c16958382.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己是否有空余的主要怪兽区，用于接纳特殊召唤的这张卡。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查额外卡组中是否存在1张以上满足spfilter条件的「罪」怪兽，可作为特殊召唤手续除外的对象。
		and Duel.IsExistingMatchingCard(c16958382.spfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 检查自己场上·墓地是否存在1张以上满足spfilter2条件的卡（持有48829461效果且可作为代价除外），作为替代素材。
	local b2=Duel.IsExistingMatchingCard(c16958382.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	-- 返回是否满足任一素材条件，且双方场上不存在表侧表示的另一张「罪 范式龙」。
	return (b1 or b2) and not Duel.IsExistingMatchingCard(c16958382.codefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤的选择阶段：汇总可作为特殊召唤手续除外的候选卡（额外卡组的「罪」怪兽及场上·墓地的替代素材），让玩家选择1张；若选择替代素材，则消耗其48829461效果的使用次数，并将所选卡保存供后续除外。
function c16958382.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 若自己有可用怪兽区，才允许从额外卡组选择「罪」怪兽作为除外素材。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取额外卡组中所有可除外的「罪」怪兽，加入候选组。
		local g1=Duel.GetMatchingGroup(c16958382.spfilter,tp,LOCATION_EXTRA,0,nil)
		g:Merge(g1)
	end
	-- 获取场上·墓地中可作为替代素材的卡，加入候选组。
	local g2=Duel.GetMatchingGroup(c16958382.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 显示“请选择要除外的卡”的提示，供玩家选择特殊召唤手续除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		if g2:IsContains(tc) then
			local te=tc:IsHasEffect(48829461,tp)
			te:UseCountLimit(tp)
		end
		return true
	else return false end
end
-- 特殊召唤的处理阶段：取出此前选择的卡并将其除外，完成特殊召唤手续。
function c16958382.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选择的卡以表侧表示除外（REASON_SPSUMMON），作为这次特殊召唤的代价。
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 自我破坏条件：场上不存在「罪 世界」（卡号27564031）。
function c16958382.descon(e)
	-- 判断当前场上没有「罪 世界」，成立时这张卡将被破坏。
	return not Duel.IsEnvironment(27564031)
end
-- 筛选卡组中可作为发动代价送去墓地的「罪」系列卡。
function c16958382.cfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToGraveAsCost()
end
-- ②效果的发动代价：从卡组选1张「罪」卡送去墓地，才能发动效果。
function c16958382.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中是否存在1张以上符合条件的「罪」卡，以支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c16958382.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示“请选择要送去墓地的卡”的提示，让玩家选择代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的「罪」卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c16958382.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡作为发动代价送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选除外区中自己的表侧表示的8星同调怪兽，且该怪兽能够回到额外卡组。
function c16958382.filter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(8) and c:IsFaceup() and c:IsAbleToExtra()
end
-- ②效果发动时判定：除外区存在自己的8星同调怪兽即可发动，并设置操作信息（从除外区返回额外卡组1张）。
function c16958382.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认除外区是否存在1张以上符合条件的自己的8星同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c16958382.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置效果处理时将从除外区返回额外卡组1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：选择1张除外的自己的8星同调怪兽返回额外卡组；若成功返回且该卡在额外卡组、可特殊召唤并有空位，则询问玩家是否特殊召唤。之后在回合结束前给己方场上的非「罪」怪兽附加不能攻击的限制。
function c16958382.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要返回卡组的卡”的提示，让玩家选择要回额外卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从除外区选择1张符合条件的8星同调怪兽。
	local g=Duel.SelectMatchingCard(tp,c16958382.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽返回卡组（额外卡组）并洗牌，同时确认返回操作成功且该卡确实在额外卡组。
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		-- 检查从额外卡组特殊召唤该怪兽所需的额外怪兽区空格足够，且该怪兽满足特殊召唤条件。
		and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否将返回额外卡组的该怪兽特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(16958382,1)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选择的8星同调怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不用「罪」怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16958382.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“非「罪」怪兽不能攻击”的限制效果注册到场上，作用于tp玩家，回合结束重置。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制的过滤函数：非「罪」系列怪兽不能攻击。
function c16958382.atktg(e,c)
	return not c:IsSetCard(0x23)
end
