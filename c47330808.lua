--ホルスの先導－ハーピ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合，以自己·对方的墓地·除外状态的卡合计2张为对象才能发动。那2张卡加入持有者手卡或那2张卡回到卡组。
function c47330808.initial_effect(c)
	-- 记录此卡与「王之棺」的关联，用于特殊召唤条件判断
	aux.AddCodeList(c,16528181)
	-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,47330808+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c47330808.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合，以自己·对方的墓地·除外状态的卡合计2张为对象才能发动。那2张卡加入持有者手卡或那2张卡回到卡组。
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
-- 过滤函数：检查场上是否存在「王之棺」
function c47330808.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- 特殊召唤条件函数：判断是否满足在墓地特殊召唤的条件
function c47330808.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 判断当前玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家场上有「王之棺」存在
		and Duel.IsExistingMatchingCard(c47330808.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：检查离开场上的卡是否为己方控制且因对方效果离开
function c47330808.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- 诱发效果条件函数：判断是否有己方的卡因对方效果离开场上
function c47330808.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47330808.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数：检查目标卡是否可以回到手牌或卡组
function c47330808.tgfilter(c,tp)
	return c:IsAbleToDeck() or c:IsAbleToHand()
end
-- 效果处理目标选择函数：选择2张可返回手牌或卡组的卡
function c47330808.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择目标的条件，即存在2张可返回手牌或卡组的卡
	if chk==0 then return Duel.IsExistingTarget(c47330808.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2张可返回手牌或卡组的卡作为效果处理对象
	local g=Duel.SelectTarget(tp,c47330808.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,2,2,nil)
	if not g:FilterCount(Card.IsAbleToHand,nil,e)==g:GetCount() then
		-- 设置操作信息：将选中的2张卡送入卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	elseif not g:FilterCount(Card.IsAbleToDeck,nil,e)==g:GetCount() then
		-- 设置操作信息：将选中的2张卡送入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
	end
	-- 设置操作信息：标记这2张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
-- 效果处理函数：根据选择决定将卡送入手牌或卡组
function c47330808.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的处理目标
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()==2 then
		-- 判断是否满足将卡送入手牌的条件，若不能则询问玩家选择送入卡组
		if tg:FilterCount(Card.IsAbleToHand,nil)==2 and (tg:FilterCount(Card.IsAbleToDeck,nil)<2 or Duel.SelectOption(tp,aux.Stringid(47330808,2),aux.Stringid(47330808,3))==0) then  --"加入手卡/回到卡组"
			-- 将选中的卡送入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			elseif tg:FilterCount(Card.IsAbleToDeck,nil)==2 then
				-- 将选中的卡送入卡组并洗牌
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
