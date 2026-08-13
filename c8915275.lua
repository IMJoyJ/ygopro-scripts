--エビル・ボックス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「卡通世界」存在的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用。
-- ●从卡组选1张「卡通」陷阱卡加入手卡或在自己场上盖放。
-- ②：只要场上有「卡通世界」存在，这张卡当作卡通怪兽使用。
-- ③：自己·对方回合1次，以自己或对方的墓地1张卡为对象才能发动。那张卡回到卡组最下面。
local s,id,o=GetID()
-- 初始化卡片效果：依次注册①手卡特殊召唤的起动效果、②当作卡通怪兽使用的永续效果、③将墓地卡返回卡组最下面的诱发即时效果
function s.initial_effect(c)
	-- 在这张卡上登记卡名「卡通世界」（15259703），供其他卡的效果参照
	aux.AddCodeList(c,15259703)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「卡通世界」存在的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用。●从卡组选1张「卡通」陷阱卡加入手卡或在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
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
	e3:SetDescription(aux.Stringid(id,1))  --"回收墓地"
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
-- 过滤函数：判断卡片是否为表侧表示的「卡通世界」（15259703）
function s.cfilter1(c)
	return c:IsCode(15259703) and c:IsFaceup()
end
-- ①效果的发动条件：检查自己场上是否存在表侧表示的「卡通世界」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「卡通世界」，存在则满足发动条件
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的目标函数：先确认自己主要怪兽区有空位且这张卡可以从手卡特殊召唤，再设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己主要怪兽区有空格，并且这张卡符合特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将把自己（这张卡）特殊召唤，用于其他卡对特殊召唤效果的检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：筛选卡组中的「卡通」陷阱卡，且该卡可以加入手卡或可以盖放
function s.thfilter(c)
	if not (c:IsSetCard(0x62) and c:IsType(TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- ①效果的处理：先把这张卡从手卡特殊召唤，然后若卡组有可用的「卡通」陷阱卡且玩家选择适用，则从卡组选1张加入手卡或在自己场上盖放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡仍与连锁相关时，把这张卡从手卡攻击表示特殊召唤到自己场上，并确认特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 确认卡组中存在至少1张满足条件（可加入手卡或可盖放）的「卡通」陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否适用从卡组选「卡通」陷阱卡的效果，选择「是」才继续处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选陷阱卡？"
		-- 中断当前效果处理，使之后的选卡处理与特殊召唤不视为同时处理（错开时点）
		Duel.BreakEffect()
		-- 向玩家发送选择提示：请选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家从卡组选择1张满足条件的「卡通」陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 若该卡可以加入手卡，且（不能盖放或玩家在「加入手卡」与「盖放」的选项中选择了加入手卡），则进入加入手卡的处理分支
			if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
				-- 将选择的「卡通」陷阱卡以效果原因加入持有者手卡
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方玩家展示（确认）这张加入手卡的卡
				Duel.ConfirmCards(1-tp,tc)
			elseif tc:IsSSetable() then
				-- 将选择的「卡通」陷阱卡在自己魔法·陷阱区域盖放
				Duel.SSet(tp,tc)
			end
		end
	end
end
-- 过滤函数：判断卡片是否为表侧表示的「卡通世界」（15259703）
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- ②永续效果的适用条件：检查双方场上是否存在表侧表示的「卡通世界」
function s.addcon(e)
	-- 检查双方任一玩家的场上是否存在至少1张表侧表示的「卡通世界」，存在则这张卡当作卡通怪兽使用
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ③效果的目标函数：以自己或对方墓地1张可以回到卡组的卡为对象，并设置返回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 对象合法性检查：被选择的卡必须位于墓地且可以回到卡组
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己或对方的墓地选择1张可以回到卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：本连锁将把对象卡返回卡组，用于其他卡的发动检测
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ③效果的处理：若对象卡仍与连锁相关且不受「王家长眠之谷」影响，则将那张卡回到卡组最下面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（墓地的那张卡）
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与连锁相关，并且不受「王家长眠之谷」的影响（可正常处理）
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡以效果原因送回持有者卡组最下面
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
