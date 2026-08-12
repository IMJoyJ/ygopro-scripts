--Sin Tune
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「罪」怪兽被战斗或者对方的效果破坏的场合才能发动。自己从卡组抽2张。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「罪」怪兽被战斗以外破坏的场合，把墓地的这张卡除外才能发动。从卡组把1只「罪」怪兽加入手卡。
function c44763696.initial_effect(c)
	-- ①：自己场上的表侧表示的「罪」怪兽被战斗或者对方的效果破坏的场合才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,44763696)
	e1:SetCondition(c44763696.condition)
	e1:SetTarget(c44763696.target)
	e1:SetOperation(c44763696.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「罪」怪兽被战斗以外破坏的场合，把墓地的这张卡除外才能发动。从卡组把1只「罪」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,44763697)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c44763696.thcon)
	e2:SetTarget(c44763696.thtg)
	e2:SetOperation(c44763696.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：破坏前控制者为玩家、位置在主要怪兽区、正面表示、种族为「罪」、破坏原因为战斗或对方效果
function c44763696.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x23)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 满足条件的被破坏怪兽数量大于等于1
function c44763696.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44763696.cfilter,1,nil,tp)
end
-- 效果处理时检查玩家是否可以抽2张卡
function c44763696.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁效果的操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果：让目标玩家抽2张卡
function c44763696.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤条件：破坏前控制者为玩家、位置在主要怪兽区、正面表示、种族为「罪」、破坏原因为非战斗
function c44763696.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x23) and not c:IsReason(REASON_BATTLE)
end
-- 满足条件的被破坏怪兽数量大于等于1
function c44763696.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44763696.cfilter2,1,nil,tp)
end
-- 检索卡组中种族为「罪」的怪兽
function c44763696.thfilter(c)
	return c:IsSetCard(0x23) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时检查卡组中是否存在满足条件的卡
function c44763696.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44763696.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁效果的操作信息为从卡组将1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果：从卡组选择1只「罪」怪兽加入手牌
function c44763696.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c44763696.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
