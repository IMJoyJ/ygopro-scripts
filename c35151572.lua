--灰滅せし都の呪術師
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己的墓地·除外状态的3只炎族怪兽为对象才能发动。那些怪兽回到卡组。这个效果让「灰灭」怪兽回去的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」加入手卡。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数，将①的特殊召唤规则效果和②的起动效果注册到卡片上。
function s.initial_effect(c)
	-- 调用辅助函数，记录此卡的效果文中提及的卡号3055018（即「灰灭之都 奥布西地暮」），用于规则上视为记载有该卡名。
	aux.AddCodeList(c,3055018)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己的墓地·除外状态的3只炎族怪兽为对象才能发动。那些怪兽回到卡组。这个效果让「灰灭」怪兽回去的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」加入手卡。
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
-- 定义过滤器：判断卡片是否为表侧表示且卡号为3055018（「灰灭之都 奥布西地暮」）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- 特殊召唤规则效果的条件函数：若没有指定怪兽c则视为允许；若指定，则检查操作者的主要怪兽区是否有空位，且场地区存在表侧表示符合条件的「灰灭之都 奥布西地暮」。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家主要怪兽区有空位，同时对方的场地区存在至少1张表侧表示且卡号为3055018的卡片。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 定义过滤器：选择对象需要满足表侧表示（或可视为表侧）、炎族、且可以回到卡组的卡。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_PYRO) and c:IsAbleToDeck()
end
-- 效果②的发动目标选择函数：在己方墓地·除外状态中，选择3只满足条件的炎族怪兽作为对象，并设置回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 效果发动时合法性检查：确认己方墓地·除外状态存在至少3只可回卡组的炎族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,3,nil) end
	-- 给玩家发送选择提示信息，提示文字为‘请选择要返回卡组的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从己方墓地·除外状态中选3只满足条件的炎族怪兽，并设为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：本连锁处理中包含将3张卡返回卡组的效果分类（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- 定义过滤器：筛选卡号为3055018（「灰灭之都 奥布西地暮」）且可以加入手卡的卡。
function s.thfilter(c)
	return c:IsCode(3055018) and c:IsAbleToHand()
end
-- 定义过滤器：筛选具有「灰灭」字段（0x1ad）且位于卡组或额外卡组的卡。
function s.rtfilter(c)
	return c:IsSetCard(0x1ad) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果②的处理函数：将对象卡送回卡组洗牌，若实际送回的是「灰灭」怪兽，则选择是否从卡组把「灰灭之都 奥布西地暮」加入手卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象，并筛选出仍与该效果相关的对象卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将对象卡以效果原因送回持有者卡组并洗牌；若没有实际送回任意卡则终止处理。
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		-- 获取刚才送回卡组操作实际处理的卡片组。
		local g=Duel.GetOperatedGroup()
		if not g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
		if g:IsExists(s.rtfilter,1,nil)
			-- 检查己方卡组是否存在至少1张「灰灭之都 奥布西地暮」且可以加入手卡。
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			-- 弹出选择询问，让玩家决定是否追加把「灰灭之都 奥布西地暮」加入手卡。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「灰灭之都 奥布西地暮」加入手卡？"
			-- 中断当前效果，使后续检索不入连锁的追加处理独立结算，避免错过时点。
			Duel.BreakEffect()
			-- 发送选择提示，提示玩家选择要加入手卡的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从己方卡组选择1张「灰灭之都 奥布西地暮」。
			local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的「灰灭之都 奥布西地暮」加入持有者手卡。
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片。
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end
