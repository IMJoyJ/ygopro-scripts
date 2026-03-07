--聖騎士の盾持ち
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤成功的场合，从自己墓地把1只光属性怪兽除外才能发动。自己从卡组抽1张。
-- ②：把手卡·场上的这张卡除外才能发动。从卡组把1只6星以下的兽族·风属性怪兽加入手卡。
function c34242278.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，从自己墓地把1只光属性怪兽除外才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34242278,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,34242278)
	e1:SetCost(c34242278.drcost)
	e1:SetTarget(c34242278.drtg)
	e1:SetOperation(c34242278.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把手卡·场上的这张卡除外才能发动。从卡组把1只6星以下的兽族·风属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34242278,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e3:SetCountLimit(1,34242278)
	-- 效果的发动需要将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c34242278.thtg)
	e3:SetOperation(c34242278.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查玩家是否拥有光属性且可作为除外费用的怪兽
function c34242278.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 效果的发动费用：选择1只光属性怪兽除外
function c34242278.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c34242278.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c34242278.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标为抽卡
function c34242278.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的处理：执行抽卡
function c34242278.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：检查卡组中是否存在6星以下的风属性兽族怪兽
function c34242278.thfilter(c)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 设置效果的目标为从卡组检索并加入手牌
function c34242278.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34242278.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果的操作信息为从卡组检索并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理：从卡组检索并加入手牌
function c34242278.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1只6星以下的风属性兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c34242278.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
