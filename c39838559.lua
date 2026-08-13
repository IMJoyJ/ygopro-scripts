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
	-- 设置①效果仅作用于场上「方程式运动员」字段的怪兽（通过字段判定筛选对象）。
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
	-- 这个卡名的③的效果1回合只能使用1次。③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员赛道大奖赛」以外的1张「方程式运动员」卡加入手卡。
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
-- 判断当前是否为战斗阶段（从战斗阶段开始到战斗阶段结束），作为①效果仅在战斗阶段内提升等级的适用条件。
function c39838559.lvcon(e)
	-- 获取当前游戏阶段，用于判断是否处于战斗阶段区间。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- ②效果的发动条件：被战斗破坏送去墓地的怪兽是己方表侧表示的「方程式运动员」怪兽，且该怪兽与对方怪兽进行了战斗并处于战斗相关状态，满足“自己的「方程式运动员」怪兽战斗破坏对方怪兽时”。
function c39838559.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0x107) and rc:IsControler(tp)
end
-- ②效果的发动目标处理：在发动时确认自己能否抽1张卡，并记录抽卡玩家为自己、抽卡数量为1，同时将操作信息标记为抽卡效果。
function c39838559.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk=0）检查自己是否可以进行1张卡的抽卡，若不能则效果无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设置为发动者自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：声明本次连锁包含抽卡效果，由己方玩家抽1张卡（targets为nil，因为抽卡不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从连锁信息中取出目标玩家和抽卡数量，执行让该玩家抽相应数量的卡。
function c39838559.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家（抽卡玩家）和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因让玩家p抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡被效果破坏，且破坏前在场上表侧表示，符合“场上的表侧表示的这张卡被效果破坏的场合”。
function c39838559.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索过滤器：选择卡组中「方程式运动员」字段的卡，排除「方程式运动员赛道大奖赛」自身，且能够加入手牌。
function c39838559.thfilter2(c)
	return c:IsSetCard(0x107) and not c:IsCode(39838559) and c:IsAbleToHand()
end
-- ③效果的目标处理：检查卡组中是否存在至少1张满足检索条件的「方程式运动员」卡，并设置操作为从卡组检索加入手牌。
function c39838559.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk=0）检查卡组是否存在至少1张满足thfilter2条件的卡，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39838559.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁为检索+回手牌效果，预期从卡组将1张卡加入持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：提示玩家从卡组选择1张满足条件的「方程式运动员」卡加入手牌，若选择成功则展示给对方确认。
function c39838559.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足thfilter2条件的「方程式运动员」卡。
	local g=Duel.SelectMatchingCard(tp,c39838559.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者手牌（nil表示回到持有者手牌），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
