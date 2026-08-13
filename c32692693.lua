--ベアルクティ・ラディエーション
-- 效果：
-- 这张卡发动的场合，给这张卡放置7个指示物来发动。
-- ①：「北极天熊辐射」在自己场上只能有1张表侧表示存在。
-- ②：每次从手卡·额外卡组有「北极天熊」怪兽特殊召唤，把这张卡1个指示物取除才能发动。自己从卡组抽1张。
-- ③：自己·对方的结束阶段，以「北极天熊辐射」以外的自己墓地1张「北极天熊」卡为对象才能发动。那张卡回到卡组。
function c32692693.initial_effect(c)
	c:SetUniqueOnField(1,0,32692693)
	c:EnableCounterPermit(0x60)
	-- 「这张卡发动的场合，给这张卡放置7个指示物来发动。」
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32692693.target)
	c:RegisterEffect(e1)
	-- 「这张卡发动的场合，给这张卡放置7个指示物来发动。」（本行是效果外文本，用于使这张卡可放置北极天熊指示物）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_COUNTER_PERMIT+0x60)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c32692693.ctpermit)
	c:RegisterEffect(e2)
	-- 「②：每次从手卡·额外卡组有「北极天熊」怪兽特殊召唤，把这张卡1个指示物取除才能发动。自己从卡组抽1张。」
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
	-- 「③：自己·对方的结束阶段，以「北极天熊辐射」以外的自己墓地1张「北极天熊」卡为对象才能发动。那张卡回到卡组。」
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
-- 发动时的处理函数：检查可以为这张卡放置7个指示物后，给这张卡放置7个北极天熊指示物。
function c32692693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性判定：若当前无法为这张卡添加7个0x60指示物则不能发动。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x60,7,c) end
	c:AddCounter(0x60,7)
end
-- 指示物许可条件：这张卡只有在魔陷区且处于连锁处理中（即发动时）才允许放置指示物。
function c32692693.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 筛选从手卡·额外卡组特殊召唤成功的表侧表示「北极天熊」怪兽。
function c32692693.cfilter(c)
	return c:IsSetCard(0x163) and c:IsFaceup() and c:IsPreviousLocation(LOCATION_HAND+LOCATION_EXTRA)
end
-- 诱发条件：当这次特殊召唤的怪兽中存在满足cfilter的怪兽时，效果可以发动。
function c32692693.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32692693.cfilter,1,nil)
end
-- 发动代价：取除这张卡1个北极天熊指示物作为发动的COST。
function c32692693.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x60,1,REASON_COST) end
	c:RemoveCounter(tp,0x60,1,REASON_COST)
end
-- 抽卡效果的发动时处理：设定抽卡玩家为自己、抽卡数量为1，并登记抽卡操作信息。
function c32692693.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 登记操作信息：效果将执行抽卡，对象玩家为自己，预计抽1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理函数：根据连锁信息让对应玩家抽对应数量的卡。
function c32692693.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出连锁中保存的对象玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：玩家p抽d张卡，抽卡理由为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 筛选符合条件的对象卡：自己墓地的「北极天熊」卡、不是「北极天熊辐射」本身、且能返回卡组。
function c32692693.tdfilter(c)
	return c:IsSetCard(0x163) and not c:IsCode(32692693) and c:IsAbleToDeck()
end
-- 取对象效果的目标处理：从自己墓地选择1张满足条件的「北极天熊」卡作为对象，并设置回卡组的操作信息。
function c32692693.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32692693.tdfilter(chkc) end
	-- 发动合法性判定：自己墓地存在1张满足tdfilter的卡可以选择。
	if chk==0 then return Duel.IsExistingTarget(c32692693.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出“选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张满足tdfilter的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c32692693.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：效果将把对象g返回卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 回卡组效果的处理：将效果对象卡返回持有者卡组并洗切。
function c32692693.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中因取对象而确定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡返回持有者卡组并洗切，理由为效果。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
