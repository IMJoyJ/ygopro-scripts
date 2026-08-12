--ベアルクティ・ラディエーション
-- 效果：
-- 这张卡发动的场合，给这张卡放置7个指示物来发动。
-- ①：「北极天熊辐射」在自己场上只能有1张表侧表示存在。
-- ②：每次从手卡·额外卡组有「北极天熊」怪兽特殊召唤，把这张卡1个指示物取除才能发动。自己从卡组抽1张。
-- ③：自己·对方的结束阶段，以「北极天熊辐射」以外的自己墓地1张「北极天熊」卡为对象才能发动。那张卡回到卡组。
function c32692693.initial_effect(c)
	c:SetUniqueOnField(1,0,32692693)
	c:EnableCounterPermit(0x60)
	-- 这张卡发动的场合，给这张卡放置 7 个指示物来发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32692693.target)
	c:RegisterEffect(e1)
	-- 这张卡发动的场合，给这张卡放置 7 个指示物来发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_COUNTER_PERMIT+0x60)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c32692693.ctpermit)
	c:RegisterEffect(e2)
	-- ②：每次从手卡·额外卡组有「北极天熊」怪兽特殊召唤，把这张卡 1 个指示物取除才能发动。自己从卡组抽 1 张。
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
	-- ③：自己·对方的结束阶段，以「北极天熊辐射」以外的自己墓地 1 张「北极天熊」卡为对象才能发动。那张卡回到卡组。
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
-- 检查能否放置 7 个指示物，若能则给这张卡放置 7 个指示物。
function c32692693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查当前玩家能否向这张卡添加 7 个 0x60 类型的指示物。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x60,7,c) end
	c:AddCounter(0x60,7)
end
-- 设定指示物允许条件，当这张卡在魔法陷阱区且正在连锁处理时允许放置指示物。
function c32692693.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 筛选是否是「北极天熊」怪兽且为表侧表示并从手卡·额外卡组特殊召唤的卡片。
function c32692693.cfilter(c)
	return c:IsSetCard(0x163) and c:IsFaceup() and c:IsPreviousLocation(LOCATION_HAND+LOCATION_EXTRA)
end
-- 检查特殊召唤成功的怪兽组中是否存在满足条件的「北极天熊」怪兽。
function c32692693.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32692693.cfilter,1,nil)
end
-- 检查能否取除 1 个指示物作为成本，若能则取除这张卡的 1 个指示物。
function c32692693.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x60,1,REASON_COST) end
	c:RemoveCounter(tp,0x60,1,REASON_COST)
end
-- 检查玩家能否抽卡，设置对象玩家和参数，并设定操作信息为抽卡。
function c32692693.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以抽 1 张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为 1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡类别，目标玩家为当前玩家，预计抽卡数量为 1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 获取对象玩家和参数，执行抽卡效果。
function c32692693.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家 p 以效果原因抽 d 张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 筛选是否是「北极天熊」卡且不是「北极天熊辐射」本身并能返回卡组的卡片。
function c32692693.tdfilter(c)
	return c:IsSetCard(0x163) and not c:IsCode(32692693) and c:IsAbleToDeck()
end
-- 检查是否存在符合条件的对象，提示玩家选择，选择墓地 1 张对象卡，并设置操作信息为返回卡组。
function c32692693.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32692693.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少 1 张满足筛选条件的「北极天熊」卡。
	if chk==0 then return Duel.IsExistingTarget(c32692693.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示提示消息，请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择 1 张满足条件的卡片作为效果对象。
	local g=Duel.SelectTarget(tp,c32692693.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为返回卡组类别，对象为选择的卡片组，数量为 1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 获取效果对象，若该卡仍与效果关联，则将其送回卡组顶端并洗牌。
function c32692693.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡片送回持有者卡组顶端并标记需要洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
