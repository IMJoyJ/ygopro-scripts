--光来する奇跡
-- 效果：
-- ①：作为这张卡的发动时的效果处理，从手卡·卡组选1只龙族·1星怪兽在卡组最上面放置。
-- ②：双方不能让场上的「星尘龙」以及有那个卡名记述的同调怪兽回到额外卡组。
-- ③：同调怪兽特殊召唤的场合才能发动。从以下效果选1个适用。这个回合，自己的「光来的奇迹」的效果不能有相同效果适用。
-- ●自己从卡组抽1张。
-- ●从手卡把1只调整特殊召唤。
function c365213.initial_effect(c)
	-- 记录此卡效果文本上记载着星尘龙的卡名
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
	-- ③：同调怪兽特殊召唤的场合才能发动。从以下效果选1个适用。这个回合，自己的「光来的奇迹」的效果不能有相同效果适用。
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
-- 过滤函数，用于筛选龙族1星怪兽，包括已在卡组或可送回卡组的怪兽
function c365213.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(1) and (c:IsAbleToDeck() or c:IsLocation(LOCATION_DECK))
end
-- 判断是否满足①效果的发动条件，即手卡或卡组是否存在龙族1星怪兽
function c365213.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果的发动条件，即手卡或卡组是否存在龙族1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c365213.tdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
end
-- ①效果的发动处理，选择并放置龙族1星怪兽到卡组最上方
function c365213.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 获取满足条件的龙族1星怪兽组
	local g=Duel.GetMatchingGroup(c365213.tdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	if #g>0 then
		-- 提示玩家选择要返回卡组的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsLocation(LOCATION_DECK) then
			-- 洗切玩家卡组
			Duel.ShuffleDeck(tp)
			-- 将选中的怪兽移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认玩家卡组最上方的卡
			Duel.ConfirmDecktop(tp,1)
		else
			-- 确认对方玩家选中的怪兽
			Duel.ConfirmCards(1-tp,tc)
			-- 将选中的怪兽送回卡组最上方
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 限制效果，禁止星尘龙或带有星尘龙记述的同调怪兽回到卡组
function c365213.tdlimit(e,c)
	-- 限制效果，禁止星尘龙或带有星尘龙记述的同调怪兽回到卡组
	return (c:IsCode(44508094) or c:IsType(TYPE_SYNCHRO) and aux.IsCodeListed(c,44508094)) and c:IsOnField()
end
-- 过滤函数，用于筛选场上存在的同调怪兽
function c365213.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 判断是否满足③效果的发动条件，即是否有同调怪兽被特殊召唤
function c365213.opcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c365213.cfilter,1,nil)
end
-- 过滤函数，用于筛选可特殊召唤的调整怪兽
function c365213.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断③效果是否可以发动，即是否满足抽卡或特殊召唤的条件
function c365213.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断玩家是否可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
		-- 判断是否已使用过抽卡效果
		and Duel.GetFlagEffect(tp,365213)==0
	-- 判断玩家场上是否有特殊召唤调整怪兽的空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在可特殊召唤的调整怪兽
		and Duel.IsExistingMatchingCard(c365213.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 判断是否已使用过特殊召唤效果
		and Duel.GetFlagEffect(tp,365214)==0
	if chk==0 then return b1 or b2 end
end
-- ③效果的发动处理，选择并执行抽卡或特殊召唤效果
function c365213.opop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
		-- 判断是否已使用过抽卡效果
		and Duel.GetFlagEffect(tp,365213)==0
	-- 判断玩家场上是否有特殊召唤调整怪兽的空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在可特殊召唤的调整怪兽
		and Duel.IsExistingMatchingCard(c365213.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 判断是否已使用过特殊召唤效果
		and Duel.GetFlagEffect(tp,365214)==0
	local op=0
	-- 当两个效果都可选时，让玩家选择效果
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(365213,1),aux.Stringid(365213,2))  --"自己从卡组抽1张/从手卡把1只调整特殊召唤"
	-- 当仅可抽卡时，让玩家选择抽卡效果
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(365213,1))  --"自己从卡组抽1张"
	-- 当仅可特殊召唤时，让玩家选择特殊召唤效果
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(365213,2))+1  --"从手卡把1只调整特殊召唤"
	else return end
	if op==0 then
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 注册抽卡效果已使用的标识
		Duel.RegisterFlagEffect(tp,365213,RESET_PHASE+PHASE_END,0,1)
	else
		-- 提示玩家选择要特殊召唤的调整怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的调整怪兽
		local g=Duel.SelectMatchingCard(tp,c365213.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的调整怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 注册特殊召唤效果已使用的标识
		Duel.RegisterFlagEffect(tp,365214,RESET_PHASE+PHASE_END,0,1)
	end
end
