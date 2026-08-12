--魔救の奇石－ティアマイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「魔救」卡的效果特殊召唤的场合才能发动。从卡组把「魔救之奇石-提亚玛特晶石」以外的1张「魔救」卡加入手卡。那之后，可以从手卡把1只岩石族怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只岩石族同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡回到卡组最上面。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①效果为特殊召唤成功时触发的诱发选发效果，用于检索「魔救」卡并可特殊召唤岩石族怪兽；②效果为墓地发动的起动效果，取自己场上·墓地的岩石族同调怪兽为对象，使其回到额外卡组并让这张卡回到卡组最上面。
function s.initial_effect(c)
	-- ①：这张卡用「魔救」卡的效果特殊召唤的场合才能发动。从卡组把「魔救之奇石-提亚玛特晶石」以外的1张「魔救」卡加入手卡。那之后，可以从手卡把1只岩石族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只岩石族同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.dttg)
	e2:SetOperation(s.dtop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡必须是用「魔救」卡的效果特殊召唤的。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- 检索过滤条件：这张卡以外的「魔救」卡且可以加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x140) and c:IsAbleToHand()
end
-- ①效果的目标函数：确认卡组存在可加入手卡的「魔救」卡，并设置回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己卡组存在至少1张这张卡以外的可加入手卡的「魔救」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤过滤条件：岩石族怪兽且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理：从卡组选1张「魔救」卡加入手卡并让对方确认，之后若手卡有可特殊召唤的岩石族怪兽且自己主要怪兽区有空位，可以选1只从手卡特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1张满足条件的「魔救」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 把选出的卡以效果原因加入手卡，并确认实际有卡被加入手卡。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 确认加入的卡仍在手卡，且自己主要怪兽区还有空位。
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 从手卡取得所有可以特殊召唤的岩石族怪兽。
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			-- 存在可特殊召唤的岩石族怪兽时，询问玩家是否进行特殊召唤。
			if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 中断当前效果处理，使后续的特殊召唤视为不同时处理（对应效果中的「那之后」）。
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 洗切自己的手卡。
				Duel.ShuffleHand(tp)
				-- 把选出的1只岩石族怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 对象过滤条件：表侧表示的岩石族同调怪兽且可以回到额外卡组。
function s.texfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_ROCK) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- ②效果的目标函数：确认自己场上·墓地存在可作为对象的岩石族同调怪兽且这张卡可以回到卡组，选择1只为对象，并设置对象回额外卡组、这张卡回卡组的操作信息。
function s.dttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.texfilter(chkc) and chkc~=c end
	-- 发动条件检测：确认自己场上·墓地存在至少1只可成为对象的岩石族同调怪兽（这张卡除外），且这张卡可以回到卡组。
	if chk==0 then return Duel.IsExistingTarget(s.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让自己从场上·墓地选择1只岩石族同调怪兽作为对象（优先从场上选择）。
	local g=aux.SelectTargetFromFieldFirst(tp,s.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 设置操作信息：宣告作为对象的怪兽将回到额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息：宣告这张卡将回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- ②效果的处理：若作为对象的怪兽仍与连锁相关且不受王家长眠之谷影响，将其送回额外卡组，成功后若这张卡仍与连锁相关且不受王家长眠之谷影响，则把这张卡放回卡组最上面。
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽仍与连锁相关且不受王家长眠之谷影响，将其送回卡组（回额外卡组），并确认其已位于额外卡组、这张卡仍与连锁相关且不受王家长眠之谷影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 把这张卡以效果原因放回卡组最上面。
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
