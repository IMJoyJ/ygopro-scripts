--灰滅せし都の呪術師
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己的墓地·除外状态的3只炎族怪兽为对象才能发动。那些怪兽回到卡组。这个效果让「灰灭」怪兽回去的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：设置该卡的①特殊召唤和②效果各只能发动1次，且①效果为手卡特殊召唤条件，②效果为回收炎族怪兽并可能检索灰灭之都奥布西地暮
function s.initial_effect(c)
	-- 记录该卡与「灰灭之都 奥布西地暮」的关联，用于效果判定
	aux.AddCodeList(c,3055018)
	-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：以自己的墓地·除外状态的3只炎族怪兽为对象才能发动。那些怪兽回到卡组。这个效果让「灰灭」怪兽回去的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收怪兽"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场地区域是否存在「灰灭之都 奥布西地暮」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- 特殊召唤条件函数：判断是否满足手卡特殊召唤的条件，包括是否有空场和场地区域存在指定卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断是否满足手卡特殊召唤的条件，包括是否有空场和场地区域存在指定卡
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 过滤函数：检查目标是否为炎族怪兽且可送回卡组
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_PYRO) and c:IsAbleToDeck()
end
-- 效果发动时的处理函数：选择3张符合条件的怪兽作为对象并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查是否满足选择3张符合条件怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：将选择的3张怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- 过滤函数：检查是否为「灰灭之都 奥布西地暮」且可加入手牌
function s.thfilter(c)
	return c:IsCode(3055018) and c:IsAbleToHand()
end
-- 过滤函数：检查是否为灰灭卡组的怪兽且在卡组或额外卡组
function s.rtfilter(c)
	return c:IsSetCard(0x1ad) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理函数：将目标怪兽送回卡组，若其中有灰灭怪兽则可检索一张灰灭之都奥布西地暮加入手牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中被选择的目标怪兽组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标怪兽送回卡组并洗牌
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		-- 获取实际操作的怪兽组
		local g=Duel.GetOperatedGroup()
		if not g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
		if g:IsExists(s.rtfilter,1,nil)
			-- 检查卡组中是否存在「灰灭之都 奥布西地暮」
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否要将「灰灭之都 奥布西地暮」加入手牌
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「灰灭之都 奥布西地暮」加入手卡？"
			-- 中断当前效果处理，使后续处理不同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择一张「灰灭之都 奥布西地暮」加入手牌
			local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的卡加入手牌
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end
