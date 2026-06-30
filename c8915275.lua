--エビル・ボックス
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- 在卡片上记载「卡通世界」的卡名
	aux.AddCodeList(c,15259703)
	-- ①：自己场上有「卡通世界」存在的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用：从卡组选1张「卡通」陷阱卡加入手卡或在自己场上盖放。
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
	-- ②：只要场上有「卡通世界」存在，这张卡当作卡通怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.addcon)
	e2:SetValue(TYPE_TOON)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合1次，以自己或对方的墓地1张卡为对象才能发动。那张卡回到卡组最下面。
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
-- 过滤场上表侧表示的「卡通世界」
function s.cfilter1(c)
	return c:IsCode(15259703) and c:IsFaceup()
end
-- 判断特殊召唤效果的发动条件：自己场上是否存在「卡通世界」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果发动时的可行性判断与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中的「卡通」陷阱卡
function s.thfilter(c)
	if not (c:IsSetCard(0x62) and c:IsType(TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 特殊召唤效果的处理：从手卡特殊召唤，并可从卡组选1张「卡通」陷阱卡加入手卡或盖放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若卡片仍关联该连锁，则将该卡从手卡特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组中是否存在满足条件的「卡通」陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组中选1张「卡通」陷阱卡适用效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 中断当前效果以使加入手牌/盖放与特殊召唤不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要操作的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家从卡组选择1张「卡通」陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 若选择加入手牌，或者该卡不可在场上盖放
			if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
				-- 将该陷阱卡从卡组加入手牌
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方确认选中的卡片
				Duel.ConfirmCards(1-tp,tc)
			elseif tc:IsSSetable() then
				-- 将选中的陷阱卡在自己场上盖放
				Duel.SSet(tp,tc)
			end
		end
	end
end
-- 过滤场上表侧表示的「卡通世界」
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 判断当作卡通怪兽使用的发动条件：场上是否存在表侧表示的「卡通世界」
function s.addcon(e)
	-- 检查场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 墓地卡片放回卡组效果发动时的目标选择与操作信息设置
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 判断双方墓地是否存在可以返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方墓地的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 墓地卡片放回卡组效果的处理：将作为对象的卡回到卡组最下面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地卡片
	local tc=Duel.GetFirstTarget()
	-- 若卡片仍关联该连锁且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将该卡送回持有者卡组最下面
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
