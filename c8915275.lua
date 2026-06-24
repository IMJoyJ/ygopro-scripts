--エビル・ボックス
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果
function s.initial_effect(c)
	-- 记录该卡与编号为15259703的卡有关联
	aux.AddCodeList(c,15259703)
	-- 效果1：起动效果，手牌发动，可以特殊召唤自己并检索、回手或盖放陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果2：永续效果，场上存在15259703且表侧表示时，此卡变为卡通怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.addcon)
	e2:SetValue(TYPE_TOON)
	c:RegisterEffect(e2)
	-- 效果3：速攻效果，场上的此卡可发动，选择墓地一张卡送回卡组
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 过滤器函数1：检查场上是否有15259703的表侧表示卡
function s.cfilter1(c)
	return c:IsCode(15259703) and c:IsFaceup()
end
-- 效果1的发动条件：场上存在15259703的表侧表示卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在15259703的表侧表示卡
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果1的目标设定函数，判断是否可以特殊召唤自己
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤器函数2：检查卡是否为光属性陷阱卡
function s.thfilter(c)
	if not (c:IsSetCard(0x62) and c:IsType(TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 效果1的处理函数，特殊召唤自己并选择检索或盖放陷阱卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且成功特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断玩家卡组中是否存在光属性陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否发动效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从玩家卡组中选择一张光属性陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 判断所选卡是否能回手且优先级高于盖放
			if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
				-- 将卡送回玩家手牌
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 确认对方查看该卡
				Duel.ConfirmCards(1-tp,tc)
			elseif tc:IsSSetable() then
				-- 将卡盖放到玩家场上
				Duel.SSet(tp,tc)
			end
		end
	end
end
-- 过滤器函数3：检查场上是否有15259703的表侧表示卡
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果2的发动条件：场上存在15259703的表侧表示卡
function s.addcon(e)
	-- 检查场上是否存在15259703的表侧表示卡
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果3的目标设定函数，选择墓地一张可送回卡组的卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 判断玩家墓地是否存在可送回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从玩家墓地中选择一张可送回卡组的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理时要送回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果3的处理函数，将目标卡送回卡组底
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将卡送回卡组底
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
