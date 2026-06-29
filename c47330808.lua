--ホルスの先導－ハーピ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合，以自己·对方的墓地·除外状态的卡合计2张为对象才能发动。那2张卡加入持有者手卡或那2张卡回到卡组。
function c47330808.initial_effect(c)
	-- 向系统登记此卡关联「王之棺」（卡片密码：16528181）
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
	-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合，以自己·对方的墓地·除外状态的卡合计2张为对象才能发动。那2张卡加入持有者手卡或回到卡组。
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
-- 场上表侧表示存在的「王之棺」的过滤条件
function c47330808.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- 判断此卡在墓地存在时是否满足特殊召唤的规程条件
function c47330808.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否有空闲的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己场上是否存在表侧表示的「王之棺」
		and Duel.IsExistingMatchingCard(c47330808.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 自己场上原本由自己控制的卡片，因对方的效果而被移动离开场上时的过滤条件
function c47330808.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- 判断当前是否触发了自己场上其他卡片因对方效果离场的时间时点
function c47330808.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47330808.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 自己或对方墓地与除外状态中，可以加入手牌或返回卡组的卡片的过滤条件
function c47330808.tgfilter(c,tp)
	return c:IsAbleToDeck() or c:IsAbleToHand()
end
-- 墓地/除外卡片加入手牌或返回卡组效果的发动准备与对象选择
function c47330808.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查双方墓地及除外状态是否存在至少2张符合回收条件的卡
	if chk==0 then return Duel.IsExistingTarget(c47330808.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,2,nil) end
	-- 向玩家发送提示，请选择需要返回卡组或手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从双方墓地或除外状态选择合计2张卡片作为效果的对象
	local g=Duel.SelectTarget(tp,c47330808.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,2,2,nil)
	if g:FilterCount(Card.IsAbleToHand,nil,e)~=g:GetCount() then
		-- 若选中的卡片包含不能加入手牌的卡，设置操作信息为将卡片返回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	elseif g:FilterCount(Card.IsAbleToDeck,nil,e)~=g:GetCount() then
		-- 若选中的卡片包含不能返回卡组的卡，设置操作信息为将卡片加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
	end
	-- 无论如何，均将此操作的离墓属性注册给系统
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
-- 墓地/除外卡片加入手牌或返回卡组的执行
function c47330808.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联的作为对象的2张卡片
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()==2 then
		-- 当这两张卡都能加入手牌时，若它们不都能返回卡组或玩家主动选择“加入手牌”则进入加手逻辑
		if tg:FilterCount(Card.IsAbleToHand,nil)==2 and (tg:FilterCount(Card.IsAbleToDeck,nil)<2 or Duel.SelectOption(tp,aux.Stringid(47330808,2),aux.Stringid(47330808,3))==0) then  --"加入手卡/回到卡组"
			-- 将这2张卡片送回持有者的手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			elseif tg:FilterCount(Card.IsAbleToDeck,nil)==2 then
				-- 否则（或者玩家选择返回卡组分支时），将这2张卡片送回持有者卡组并洗牌
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
