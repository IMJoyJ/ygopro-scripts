--水征竜－ストリーム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把1只龙族或水属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「瀑征龙-潮龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c27415516.initial_effect(c)
	-- 将卡号26400609（瀑征龙-潮龙）登记到本卡片的卡名记载列表中，用于识别本卡效果记载的关联卡名。
	aux.AddCodeList(c,26400609)
	-- 这个卡名的效果1回合只能使用1次。①：把1只龙族或水属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「瀑征龙-潮龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27415516,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27415516)
	e1:SetCost(c27415516.spcost)
	e1:SetTarget(c27415516.sptg)
	e1:SetOperation(c27415516.spop)
	c:RegisterEffect(e1)
end
-- 判断一张手卡是否可作为代价丢弃：它是龙族或水属性，并且能被丢弃（送入墓地）。
function c27415516.costfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_WATER)) and c:IsDiscardable()
end
-- spcost的合法性检查：当chk==0时，确认该效果发动者（这张卡）自身可以丢弃，并且手牌中存在另一张满足costfilter条件的龙族/水属性怪兽。
function c27415516.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查手牌中是否存在1张除这张卡自身以外、满足costfilter（龙族或水属性且可丢弃）的卡。
		and Duel.IsExistingMatchingCard(c27415516.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家显示提示消息，要求选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家从手牌中（不含这张卡自身）选择1张满足costfilter的卡作为发动代价的素材。
	local g=Duel.SelectMatchingCard(tp,c27415516.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的代价素材和这张卡自身一起从手卡送去墓地，作为发动效果所需的代价（COST与DISCARD原因）。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 筛选特殊召唤对象：必须是卡号26400609（瀑征龙-潮龙），并且能够被玩家tp以效果e特殊召唤（检查召唤条件与苏生限制）。
function c27415516.spfilter(c,e,tp)
	return c:IsCode(26400609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg的目标合法性检查：当chk==0时，确认自己主怪兽区有空位，并且卡组中存在满足spfilter的特殊召唤对象。
function c27415516.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有空余的主要怪兽区位置，没有则条件不满足。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在1张满足spfilter（瀑征龙-潮龙且可以被特殊召唤）的卡。
		and Duel.IsExistingMatchingCard(c27415516.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次处理的操作信息：效果类别为特殊召唤，预计从卡组处理1只怪兽，因此写入CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- spop效果处理：若主怪兽区仍空，取出卡组中符合条件的「瀑征龙-潮龙」，用特殊召唤步骤将其特殊召唤，并给它附加本回合不能攻击的效果，最后完成特殊召唤。
function c27415516.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主怪兽区是否有空位，若无则中止处理（由于场上已被占满，无法特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组取得第一张满足spfilter的「瀑征龙-潮龙」，作为本次特殊召唤的候选对象。
	local tc=Duel.GetFirstMatchingCard(c27415516.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 如果找到了目标且该卡可以被特殊召唤，则先通过SpecialSummonStep将其以表侧表示特殊召唤到己方场上（nocheck/nolimit为false，正常判定召唤条件与苏生限制）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成所有特殊召唤步骤，正式结算特殊召唤并触发相关的召唤成功时点。
	Duel.SpecialSummonComplete()
end
