--ベアルクティ・ラディエーション
-- 效果：
-- 这张卡发动的场合，给这张卡放置7个指示物来发动。
-- ①：「北极天熊辐射」在自己场上只能有1张表侧表示存在。
-- ②：每次从手卡·额外卡组有「北极天熊」怪兽特殊召唤，把这张卡1个指示物取除才能发动。自己从卡组抽1张。
-- ③：自己·对方的结束阶段，以「北极天熊辐射」以外的自己墓地1张「北极天熊」卡为对象才能发动。那张卡回到卡组。
function c32692693.initial_effect(c)
	c:SetUniqueOnField(1,0,32692693)
	c:EnableCounterPermit(0x60)
	-- ①：「北极天熊辐射」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32692693.target)
	c:RegisterEffect(e1)
	-- ②：每次从手卡·额外卡组有「北极天熊」怪兽特殊召唤，把这张卡1个指示物取除才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_COUNTER_PERMIT+0x60)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c32692693.ctpermit)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段，以「北极天熊辐射」以外的自己墓地1张「北极天熊」卡为对象才能发动。那张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32692693,0))  --"抽1张卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c32692693.drcon)
	e3:SetCost(c32692693.drcost)
	e3:SetTarget(c32692693.drtg)
	e3:SetOperation(c32692693.drop)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(32692693,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetTarget(c32692693.tdtg)
	e4:SetOperation(c32692693.tdop)
	c:RegisterEffect(e4)
end
-- 将7个指示物放置到此卡上
function c32692693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以向此卡放置7个指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x60,7,c) end
	c:AddCounter(0x60,7)
end
-- 效果作用
function c32692693.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 过滤器函数：判断是否为表侧表示的「北极天熊」怪兽且来自手卡或额外卡组
function c32692693.cfilter(c)
	return c:IsSetCard(0x163) and c:IsFaceup() and c:IsPreviousLocation(LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果作用
function c32692693.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32692693.cfilter,1,nil)
end
-- 效果作用
function c32692693.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x60,1,REASON_COST) end
	c:RemoveCounter(tp,0x60,1,REASON_COST)
end
-- 效果作用
function c32692693.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用
function c32692693.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤器函数：判断是否为「北极天熊」卡且不是此卡且可以送回卡组
function c32692693.tdfilter(c)
	return c:IsSetCard(0x163) and not c:IsCode(32692693) and c:IsAbleToDeck()
end
-- 效果作用
function c32692693.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32692693.tdfilter(chkc) end
	-- 检查是否存在满足条件的墓地目标卡
	if chk==0 then return Duel.IsExistingTarget(c32692693.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地目标卡
	local g=Duel.SelectTarget(tp,c32692693.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息为送回卡组效果
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果作用
function c32692693.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
