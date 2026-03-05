--サラマングレイト・ギフト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡丢弃1只「转生炎兽」怪兽才能发动。从卡组把1只「转生炎兽」怪兽送去墓地。那之后，自己从卡组抽1张。
-- ②：用和自身同名的怪兽为素材作连接召唤的「转生炎兽」连接怪兽在自己场上存在的场合，从手卡丢弃1只「转生炎兽」怪兽才能发动。自己从卡组抽2张。
function c20788863.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：从手卡丢弃1只「转生炎兽」怪兽才能发动。从卡组把1只「转生炎兽」怪兽送去墓地。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20788863,0))  --"堆墓并抽1张卡"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,20788863)
	e2:SetCost(c20788863.cost)
	e2:SetTarget(c20788863.drtg1)
	e2:SetOperation(c20788863.drop1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：用和自身同名的怪兽为素材作连接召唤的「转生炎兽」连接怪兽在自己场上存在的场合，从手卡丢弃1只「转生炎兽」怪兽才能发动。自己从卡组抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20788863,1))  --"抽2张卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,20788863)
	e3:SetCondition(c20788863.drcon)
	e3:SetCost(c20788863.cost)
	e3:SetTarget(c20788863.drtg2)
	e3:SetOperation(c20788863.drop2)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e3)
	if not c20788863.global_check then
		c20788863.global_check=true
		-- 效果原文内容：这个卡名的①②的效果1回合只能有1次使用其中任意1个。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c20788863.valcheck)
		-- 将效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有连接召唤的「转生炎兽」怪兽作为素材时，为该怪兽标记一个flag，用于后续判断是否满足②效果的发动条件
function c20788863.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(20788863,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 过滤函数：判断手卡中是否存在可丢弃的「转生炎兽」怪兽
function c20788863.cfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果作用：检查玩家手卡是否存在满足条件的怪兽并将其丢弃作为发动cost
function c20788863.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c20788863.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡丢弃1张满足条件的怪兽
	Duel.DiscardHand(tp,c20788863.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断卡组中是否存在可送去墓地的「转生炎兽」怪兽
function c20788863.filter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果作用：检查玩家是否可以发动①效果
function c20788863.drtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c20788863.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将要抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用：选择卡组中的一只「转生炎兽」怪兽送去墓地，并洗切卡组后抽1张卡
function c20788863.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c20788863.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡送去墓地并确认其在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 将玩家卡组洗切
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数：判断场上是否存在满足条件的「转生炎兽」连接怪兽
function c20788863.lfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(20788863)~=0
end
-- 效果作用：检查是否满足②效果的发动条件
function c20788863.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的「转生炎兽」连接怪兽
	return Duel.IsExistingMatchingCard(c20788863.lfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：检查玩家是否可以发动②效果
function c20788863.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前处理的连锁的对象玩家为玩家tp
	Duel.SetTargetPlayer(tp)
	-- 设置当前处理的连锁的对象参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息：将要抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：让玩家抽2张卡
function c20788863.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
