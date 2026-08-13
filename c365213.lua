--光来する奇跡
-- 效果：
-- ①：作为这张卡的发动时的效果处理，从手卡·卡组选1只龙族·1星怪兽在卡组最上面放置。
-- ②：双方不能让场上的「星尘龙」以及有那个卡名记述的同调怪兽回到额外卡组。
-- ③：同调怪兽特殊召唤的场合才能发动。从以下效果选1个适用。这个回合，自己的「光来的奇迹」的效果不能有相同效果适用。
-- ●自己从卡组抽1张。
-- ●从手卡把1只调整特殊召唤。
function c365213.initial_effect(c)
	-- 将卡名中记述的‘星尘龙’登记到代码列表，供后续判断‘有那个卡名记述的同调怪兽’使用。
	aux.AddCodeList(c,44508094)
	-- ①：作为这张卡的发动时的效果处理，从手卡·卡组选1只龙族·1星怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c365213.target)
	e1:SetOperation(c365213.activate)
	c:RegisterEffect(e1)
	-- ②：双方不能让场上的「星尘龙」以及有那个卡名记述的同调怪兽回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c365213.tdlimit)
	c:RegisterEffect(e2)
	-- ③：同调怪兽特殊召唤的场合才能发动。从以下效果选1个适用。这个回合，自己的「光来的奇迹」的效果不能有相同效果适用。●自己从卡组抽1张。●从手卡把1只调整特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(365213,0))  --"选择效果适用"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c365213.opcon)
	e3:SetTarget(c365213.optg)
	e3:SetOperation(c365213.opop)
	c:RegisterEffect(e3)
end
-- 筛选符合条件的卡片：龙族·1星怪兽，且从手卡选择时能够回卡组，或已在卡组中。
function c365213.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(1) and (c:IsAbleToDeck() or c:IsLocation(LOCATION_DECK))
end
-- 效果发动的合法条件：自己手卡·卡组存在至少1只满足条件的龙族·1星怪兽。
function c365213.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动检测（chk==0），检查是否存在至少1张满足条件的卡片，存在才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c365213.tdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
end
-- 效果处理：从手卡·卡组选出1只龙族·1星怪兽放到卡组最上面；若从卡组选则洗切后移动，若从手卡选则展示给对方后送回卡组顶。
function c365213.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示‘请选择要返回卡组的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 获取手卡·卡组中所有满足条件的龙族·1星怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c365213.tdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	if #g>0 then
		-- 再次提示当前玩家选择要放置到卡组最上面的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsLocation(LOCATION_DECK) then
			-- 洗切当前玩家的卡组，保证卡组顺序随机后进行操作。
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最顶端。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 向当前玩家展示卡组最上方1张卡，确认放置的卡片。
			Duel.ConfirmDecktop(tp,1)
		else
			-- 向对方玩家展示选中的手牌卡。
			Duel.ConfirmCards(1-tp,tc)
			-- 将选中的手牌卡以效果原因送回持有者卡组最顶端。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- ②的限制对象判定：判断怪兽是否为星尘龙或卡名记述星尘龙的同调怪兽且在场。
function c365213.tdlimit(e,c)
	-- 返回true的条件：怪兽是星尘龙或卡名记述星尘龙的同调怪兽，且当前位于场上。
	return (c:IsCode(44508094) or c:IsType(TYPE_SYNCHRO) and aux.IsCodeListed(c,44508094)) and c:IsOnField()
end
-- 判断怪兽是否表侧表示且为同调怪兽，作为③的触发条件。
function c365213.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ③的发动条件：本次特殊召唤成功的怪兽中存在表侧表示的同调怪兽。
function c365213.opcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c365213.cfilter,1,nil)
end
-- 筛选手卡中可作为特殊召唤对象的调整怪兽，且能够被此效果特殊召唤。
function c365213.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动判定：计算两个可选效果（抽1张/特召调整）是否分别可用，且检查本回合是否已适用过对应效果；只要有一个可用即可发动。
function c365213.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断当前玩家是否可以抽1张卡。
	local b1=Duel.IsPlayerCanDraw(tp,1)
		-- 检查本回合是否尚未使用过‘抽1张’选项（flag 365213 数量为0）。
		and Duel.GetFlagEffect(tp,365213)==0
	-- 判断自己场上是否有空余的怪兽区域，用于特召调整。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在可供特殊召唤的调整怪兽。
		and Duel.IsExistingMatchingCard(c365213.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查本回合是否尚未使用过‘从手卡特召调整’选项（flag 365214 数量为0）。
		and Duel.GetFlagEffect(tp,365214)==0
	if chk==0 then return b1 or b2 end
end
-- ③的效果处理：根据两选项可用情况，让玩家选择或自动决定，执行抽1张或从手卡特召1只调整，并记录对应flag避免同回合重复适用相同效果。
function c365213.opop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行阶段判定：当前玩家是否可以抽1张卡。
	local b1=Duel.IsPlayerCanDraw(tp,1)
		-- 执行阶段判定：本回合尚未适用过‘抽1张’选项。
		and Duel.GetFlagEffect(tp,365213)==0
	-- 执行阶段判定：自己场上是否有可用怪兽区域。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 执行阶段判定：手卡中是否存在可特殊召唤的调整怪兽。
		and Duel.IsExistingMatchingCard(c365213.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 执行阶段判定：本回合尚未适用过‘从手卡特召调整’选项。
		and Duel.GetFlagEffect(tp,365214)==0
	local op=0
	-- 两个选项都可用时，让玩家在‘抽1张’和‘从手卡特召调整’中选择一项。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(365213,1),aux.Stringid(365213,2))  --"自己从卡组抽1张/从手卡把1只调整特殊召唤"
	-- 只有抽卡选项可用时，自动选择‘抽1张’（op=0）。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(365213,1))  --"自己从卡组抽1张"
	-- 只有特召选项可用时，自动选择‘从手卡特召调整’（op=1）。
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(365213,2))+1  --"从手卡把1只调整特殊召唤"
	else return end
	if op==0 then
		-- 执行抽卡：自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 为本回合已适用‘抽1张’效果注册flag，回合结束时重置。
		Duel.RegisterFlagEffect(tp,365213,RESET_PHASE+PHASE_END,0,1)
	else
		-- 提示当前玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡中选出1只满足条件的调整怪兽。
		local g=Duel.SelectMatchingCard(tp,c365213.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的调整怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 为本回合已适用‘从手卡特召调整’效果注册flag，回合结束时重置。
		Duel.RegisterFlagEffect(tp,365214,RESET_PHASE+PHASE_END,0,1)
	end
end
