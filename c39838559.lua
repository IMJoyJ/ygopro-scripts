--F.A.サーキットGP
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在战斗阶段内上升2星。
-- ②：1回合1次，自己的「方程式运动员」怪兽战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员赛道大奖赛」以外的1张「方程式运动员」卡加入手卡。
function c39838559.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在战斗阶段内上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为场上所有「方程式运动员」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107))
	e2:SetValue(2)
	e2:SetCondition(c39838559.lvcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己的「方程式运动员」怪兽战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39838559,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c39838559.drcon)
	e3:SetTarget(c39838559.drtg)
	e3:SetOperation(c39838559.drop)
	c:RegisterEffect(e3)
	-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员赛道大奖赛」以外的1张「方程式运动员」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,39838559)
	e4:SetCondition(c39838559.thcon2)
	e4:SetTarget(c39838559.thtg2)
	e4:SetOperation(c39838559.thop2)
	c:RegisterEffect(e4)
end
-- 判断当前是否处于战斗阶段内
function c39838559.lvcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 判断是否为己方「方程式运动员」怪兽在战斗阶段破坏对方怪兽
function c39838559.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0x107) and rc:IsControler(tp)
end
-- 检查玩家是否可以抽卡并设置抽卡效果信息
function c39838559.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果对象参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c39838559.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断此卡是否因效果破坏且处于表侧表示
function c39838559.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤出卡组中非此卡的「方程式运动员」怪兽
function c39838559.thfilter2(c)
	return c:IsSetCard(0x107) and not c:IsCode(39838559) and c:IsAbleToHand()
end
-- 检查卡组中是否存在满足条件的「方程式运动员」怪兽并设置检索效果信息
function c39838559.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「方程式运动员」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39838559.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索手牌效果
function c39838559.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「方程式运动员」怪兽
	local g=Duel.SelectMatchingCard(tp,c39838559.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
