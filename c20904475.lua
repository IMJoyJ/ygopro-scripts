--海瀧竜華－淵巴
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「登龙华海泷门」加入手卡。
-- ②：「海泷龙华-渊巴」以外的怪兽2只以上从手卡·卡组送去墓地的回合的自己主要阶段才能发动。这张卡从墓地特殊召唤。
-- ③：让自己场上1张表侧表示的「登龙华海泷门」回到卡组最下面才能发动。对方手卡全部除外，对方抽出那个数量。
local s,id,o=GetID()
-- 为「海泷龙华-渊巴」注册①检索、②墓地特殊召唤、③除外对方手牌并让对方抽卡的三个起动效果，并注册全局监视效果以记录本回合从手卡·卡组送去墓地的怪兽数量。
function s.initial_effect(c)
	-- 将「登龙华海泷门」（28669235）加入本卡的卡名关联列表，使本卡被视为“记载着登龙华海泷门”的卡。
	aux.AddCodeList(c,28669235)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「登龙华海泷门」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：「海泷龙华-渊巴」以外的怪兽2只以上从手卡·卡组送去墓地的回合的自己主要阶段才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：让自己场上1张表侧表示的「登龙华海泷门」回到卡组最下面才能发动。对方手卡全部除外，对方抽出那个数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"对方卡除外并抽卡"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「登龙华海泷门」加入手卡。②：「海泷龙华-渊巴」以外的怪兽2只以上从手卡·卡组送去墓地的回合的自己主要阶段才能发动。这张卡从墓地特殊召唤。③：让自己场上1张表侧表示的「登龙华海泷门」回到卡组最下面才能发动。对方手卡全部除外，对方抽出那个数量。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		-- 将全局计数效果ge1注册到双方共同的环境，使任意一方有怪兽从手卡·卡组送去墓地时都能触发计数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监视效果的操作：遍历每只被送去墓地的怪兽，若其来自手卡或卡组、不是渊巴自身、且是怪兽，则为双方玩家各添加一个本回合结束重置的标志，用来累计“渊巴以外的怪兽从手卡·卡组送去墓地”的次数。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历本次送去墓地的所有卡片eg，逐个进行处理。
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and not tc:IsCode(id)
			and tc:IsType(TYPE_MONSTER) then
			-- 为发动方玩家tp添加一个本回合结束重置的id标志，累计本回合符合条件的送墓怪兽数量。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			-- 为对方玩家1-tp也添加同样的id标志，使双方计数一致，确保任一方都能发动渊巴的②效果。
			Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- ①效果的代价函数：检查渊巴是否可从手卡丢弃，若是则将其丢弃作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将渊巴以COST+DISCARD的理由从手卡送去墓地，支付①效果的丢弃代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- ①效果的检索过滤器：卡必须是「登龙华海泷门」且能够加入手卡。
function s.thfilter(c)
	return c:IsCode(28669235) and c:IsAbleToHand()
end
-- ①效果的发动目标函数：若卡组中存在可检索的「登龙华海泷门」，则设置操作信息，准备从卡组将1张「登龙华海泷门」加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动合法性的chk阶段确认卡组至少有1张满足条件的「登龙华海泷门」可检索。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为TOHAND+SEARCH（检索并加入手卡），用于给其他卡提供正确的事件判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：由发动方从卡组选择1张「登龙华海泷门」加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求发动方选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足thfilter（即「登龙华海泷门」）的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选中的「登龙华海泷门」加入其持有者的手卡（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡，以符合检索效果的确认规则。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件函数：检查tp玩家本回合累计的id标志数量是否达到2，即已有2只以上渊巴以外的怪兽从手卡·卡组送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前tp玩家id标志的数量是否≥2，作为②效果的发动条件判定。
	return Duel.GetFlagEffect(tp,id)>=2
end
-- ②效果的目标函数：在chk阶段确认tp有主怪兽区空格，且墓地的渊巴能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查tp玩家的主要怪兽区是否有空位，用于特殊召唤渊巴。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，告知系统本次效果将把渊巴从墓地特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：若渊巴仍与效果关联且不受墓地特殊召唤限制，则将其特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认渊巴与效果仍有联系（未被重置离场），并通过王家长眠之谷的过滤，确保墓地特殊召唤合法。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将渊巴以表侧表示特殊召唤到tp玩家的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的代价过滤器：选择己方场上表侧表示的「登龙华海泷门」，且能够作为代价返回卡组最下面。
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(28669235) and c:IsAbleToDeckAsCost()
end
-- ③效果的代价函数：检查己方场上有无表侧「登龙华海泷门」可作为返回卡组的代价，有则选择1张送回卡组最下面。
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 合法性chk阶段确认己方场上存在1张表侧表示的「登龙华海泷门」可以作为③的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出选择提示，要求发动方选择要返回卡组的「登龙华海泷门」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从己方场上选择1张满足costfilter的「登龙华海泷门」。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 手动显示被选择的代价卡并记录其被选择，使连锁处理正确关联。
	Duel.HintSelection(g)
	-- 将选择的「登龙华海泷门」以代价形式送回持有者卡组最下面。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- ③效果的目标函数：获取对方全部手牌，检查它们都能被除外且对方能抽对应数量，并设置除外与抽卡的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方当前所有手牌，作为③效果的处理对象。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	-- chk阶段确认对方手牌数>0、全部手牌都能除外、并且对方可以抽这些数量的卡。
	if chk==0 then return gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc and Duel.IsPlayerCanDraw(1-tp,gc) end
	-- 设置操作信息：本次效果将除外g（对方所有手牌）中的gc张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,gc,0,0)
	-- 设置操作信息：本次效果会让对方（1-tp）抽取gc张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,gc)
end
-- ③效果的实际处理：重新获取对方手牌，若仍全部可除外，则全部除外，并按实际除外数让对方抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取对方当前手牌（防止之前已有变动），用于后续除外。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	if gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc then
		-- 将对方当前所有手牌以表侧表示除外，并返回实际除外的卡数oc。
		local oc=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		if oc>0 then
			-- 让对方玩家抽取oc张卡（即“对方抽出那个数量”）。
			Duel.Draw(1-tp,oc,REASON_EFFECT)
		end
	end
end
