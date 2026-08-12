--ホルスの先導－ハーピ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合，以自己·对方的墓地·除外状态的卡合计2张为对象才能发动。那2张卡加入持有者手卡或那2张卡回到卡组。
function c47330808.initial_effect(c)
	-- 为这张卡注册代码列表，记录其卡名中关联着「王之棺」（卡号16528181），以便按卡名引用判定
	aux.AddCodeList(c,16528181)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,47330808+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c47330808.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合，以自己·对方的墓地·除外状态的卡合计2张为对象才能发动。那2张卡加入持有者手卡或那2张卡回到卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47330808,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,47330809)
	e2:SetCondition(c47330808.descon)
	e2:SetTarget(c47330808.destg)
	e2:SetOperation(c47330808.desop)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件的过滤函数：判断卡片是否为表侧表示的「王之棺」（卡号16528181）
function c47330808.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- ①特殊召唤的发动条件：若卡片受王家长眠之谷影响则不能特殊召唤；否则要求自己怪兽区有可用空格且自己场上存在「王之棺」
function c47330808.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 判定自己主要怪兽区是否还有可用空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并判定自己场上是否存在表侧表示的「王之棺」
		and Duel.IsExistingMatchingCard(c47330808.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 离场事件的过滤函数：筛选出原本由自己控制、因对方的效果而从场上离开的卡
function c47330808.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- ②效果的触发条件：离场的卡中存在原本由自己控制且因对方效果离开的卡，且离场的卡不包括这张卡自身
function c47330808.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47330808.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 取对象过滤函数：筛选出可以回到卡组或加入手卡的卡
function c47330808.tgfilter(c,tp)
	return c:IsAbleToDeck() or c:IsAbleToHand()
end
-- ②效果的目标处理：确认双方墓地·除外区存在合计2张可作对象的卡，提示玩家选择，选定那2张卡为对象，并根据它们能否回手卡/回卡组设置对应的操作信息（回卡组或回手牌），最后设置离开墓地的操作信息
function c47330808.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果能否发动的检查：确认自己·对方的墓地·除外状态存在合计2张可以成为对象的卡
	if chk==0 then return Duel.IsExistingTarget(c47330808.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,2,nil) end
	-- 向玩家显示选择提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 以自己·对方的墓地·除外状态的卡合计2张为对象，由玩家选择并设置为效果对象
	local g=Duel.SelectTarget(tp,c47330808.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,2,2,nil)
	if g:FilterCount(Card.IsAbleToHand,nil,e)~=g:GetCount() then
		-- 若所选2张卡不能全部加入手卡，则设置操作信息为将那2张卡回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	elseif g:FilterCount(Card.IsAbleToDeck,nil,e)~=g:GetCount() then
		-- 若所选2张卡不能全部回到卡组，则设置操作信息为将那2张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
	end
	-- 设置操作信息：将有2张卡从墓地移动（用于王家长眠之谷等效果检测）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
-- ②效果的处理：取得连锁相关的对象卡，若仍为2张，则若2张都能加入手卡且（不能都回卡组或玩家选择加入手卡）则将它们加入持有者手卡，否则若2张都能回到卡组则将它们回到持有者卡组并洗切
function c47330808.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁相关联的效果对象卡组
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()==2 then
		-- 判断处理方式：若2张对象都能加入手卡，且（不能都回到卡组或玩家选择了「加入手卡」选项），则执行加入手卡
		if tg:FilterCount(Card.IsAbleToHand,nil)==2 and (tg:FilterCount(Card.IsAbleToDeck,nil)<2 or Duel.SelectOption(tp,aux.Stringid(47330808,2),aux.Stringid(47330808,3))==0) then  --"加入手卡/回到卡组"
			-- 将那2张对象卡以效果原因加入各自持有者的手卡
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			elseif tg:FilterCount(Card.IsAbleToDeck,nil)==2 then
				-- 将那2张对象卡以效果原因回到各自持有者的卡组并洗切卡组
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
