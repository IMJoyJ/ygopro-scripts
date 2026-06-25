--エビル・ボックス
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（在场上有「卡通世界」存在时从手牌特殊召唤并可检索或盖放「卡通」陷阱卡，当作卡通怪兽使用，以及在自己·对方回合将双方墓地1张卡返回卡组最下方）
function s.initial_effect(c)
	-- 记录该卡片记有卡名「卡通世界」（卡号：15259703）的事实
	aux.AddCodeList(c,15259703)
	-- 自己场上有「卡通世界」存在的场合可以发动。将这张卡从手牌特殊召唤。那之后，可以从牌组选1张「卡通」陷阱卡加入手牌或在自己场上盖放
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
	-- 只要「卡通世界」在场上存在，这张卡被视为卡通怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.addcon)
	e2:SetValue(TYPE_TOON)
	c:RegisterEffect(e2)
	-- 自己·对方回合1次，可以以自己或对方的墓地1张卡为对象发动。将那张卡返回牌组最下方
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
-- 过滤场上表侧表示「卡通世界」的过滤函数
function s.cfilter1(c)
	return c:IsCode(15259703) and c:IsFaceup()
end
-- 效果①特殊召唤效果的发动条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①特殊召唤效果的发动准备与检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的分类为特殊召唤，数量为1，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中属于「卡通」系列且是陷阱卡，并且能加入手牌或可以盖放的卡片的过滤函数
function s.thfilter(c)
	if not (c:IsSetCard(0x62) and c:IsType(TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 效果①特殊召唤与后续检索/盖放的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡与连锁相关联，且成功将其特殊召唤到自己场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 并且检查卡组中是否存在可以检索或盖放的「卡通」陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且询问玩家是否适用后续检索/盖放的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 中断效果处理，使后续检索/盖放与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家从卡组选择1张符合条件的「卡通」陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 如果该卡能加入手牌，且在其不能盖放或者玩家选择将其加入手牌的场合
			if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
				-- 将选择的卡加入手牌
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手牌的卡
				Duel.ConfirmCards(1-tp,tc)
			elseif tc:IsSSetable() then
				-- 将选择的卡在自己场上盖放
				Duel.SSet(tp,tc)
			end
		end
	end
end
-- 过滤场上表侧表示「卡通世界」的过滤函数
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果②当作卡通怪兽使用的生效条件函数
function s.addcon(e)
	-- 检查场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果③返回卡组效果的发动准备与取对象检查函数
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 在chk==0时，检查双方墓地是否存在可以返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择双方墓地中1张可以返回卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理的分类为返回卡组，数量为1，目标为选择的墓地卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果③返回卡组效果的处理函数
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡返回到持有者卡组的最下方
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
