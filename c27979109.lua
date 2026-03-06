--武装鍛錬
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
-- ②：自己场上有装备魔法卡存在的场合，从自己墓地让1只战士族·炎属性怪兽或者二重怪兽回到卡组最下面才能发动。自己从卡组抽1张。
function c27979109.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27979109,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,27979109)
	e2:SetCondition(c27979109.thcon)
	e2:SetTarget(c27979109.thtg)
	e2:SetOperation(c27979109.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上有装备魔法卡存在的场合，从自己墓地让1只战士族·炎属性怪兽或者二重怪兽回到卡组最下面才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27979109,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,27979110)
	e3:SetCondition(c27979109.drcon)
	e3:SetCost(c27979109.drcost)
	e3:SetTarget(c27979109.drtg)
	e3:SetOperation(c27979109.drop)
	c:RegisterEffect(e3)
end
c27979109.has_text_type=TYPE_DUAL
-- 效果发动条件：只有在自己的抽卡阶段才能发动
function c27979109.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return tp==Duel.GetTurnPlayer()
end
-- 过滤函数：筛选可加入手牌的装备魔法卡
function c27979109.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果发动时点：设置效果处理信息，准备从卡组·墓地选1张装备魔法卡加入手牌
function c27979109.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：当前玩家可以进行通常抽卡且卡组或墓地存在装备魔法卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c27979109.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 禁止当前玩家进行通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	-- 设置效果处理信息：将1张装备魔法卡从卡组·墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：选择并处理装备魔法卡加入手牌
function c27979109.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的装备魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27979109.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的装备魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的装备魔法卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选场上存在的装备魔法卡
function c27979109.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 效果发动条件：场上有装备魔法卡存在
function c27979109.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有装备魔法卡存在
	return Duel.IsExistingMatchingCard(c27979109.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 过滤函数：筛选可作为代价送回卡组的战士族·炎属性怪兽或二重怪兽
function c27979109.costfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)) or c:IsType(TYPE_DUAL)) and c:IsAbleToDeckAsCost()
end
-- 效果发动时点：设置效果处理信息，准备支付代价并抽卡
function c27979109.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：墓地存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27979109.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c27979109.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽送回卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果发动时点：设置效果处理信息，准备抽卡
function c27979109.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：当前玩家可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的目标玩家为效果发动者
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息：从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：执行抽卡效果
function c27979109.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
