--走破するガイア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方在战斗阶段中不能把效果发动。
-- ②：可以从以下效果选择1个发动。
-- ●把手卡1只「暗黑骑士 盖亚」怪兽给对方观看才能发动。从卡组把1只龙族·5星怪兽加入手卡。
-- ●把手卡1只龙族·5星怪兽给对方观看才能发动。从卡组把1只「暗黑骑士 盖亚」怪兽加入手卡。
function c2106266.initial_effect(c)
	-- 将效果文本中提到的「龙骑士 盖亚」（卡号66889139）登记为本卡的“记载卡名”，使规则上本卡视为记载了该卡名。
	aux.AddCodeList(c,66889139)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方在战斗阶段中不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(1)
	e1:SetCondition(c2106266.actcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：可以从以下效果选择1个发动。●把手卡1只「暗黑骑士 盖亚」怪兽给对方观看才能发动。从卡组把1只龙族·5星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2106266,0))  --"龙族·5星怪兽加入手卡"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,2106266)
	e2:SetCost(c2106266.cost1)
	e2:SetTarget(c2106266.target1)
	e2:SetOperation(c2106266.activate1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(2106266,1))  --"「暗黑骑士 盖亚」怪兽加入手卡"
	e3:SetCost(c2106266.cost2)
	e3:SetTarget(c2106266.target2)
	e3:SetOperation(c2106266.activate2)
	c:RegisterEffect(e3)
end
-- 筛选条件：卡片须为表侧表示且卡号是66889139（「龙骑士 盖亚」），用于确认自己场上是否存在「龙骑士 盖亚」。
function c2106266.actfilter(c)
	return c:IsFaceup() and c:IsCode(66889139)
end
-- ①效果的适用条件：自己的怪兽区存在表侧表示的「龙骑士 盖亚」，且当前阶段处于战斗阶段开始到战斗阶段结束之间。
function c2106266.actcon(e)
	-- 获取当前游戏阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	local tp=e:GetHandlerPlayer()
	-- 当满足“自己场上有表侧「龙骑士 盖亚」”且“当前为战斗阶段（PHASE_BATTLE_START至PHASE_BATTLE）”时，①效果生效，对方不能在战斗阶段发动效果。
	return Duel.IsExistingMatchingCard(c2106266.actfilter,tp,LOCATION_MZONE,0,1,nil) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- cost1的过滤条件：手卡中是「暗黑骑士 盖亚」系列（0xbd）的怪兽卡，且当前不是公开状态，用于作为展示给对方确认的代价。
function c2106266.costfilter1(c)
	return c:IsSetCard(0xbd) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 第一个分支效果的发动代价：从手卡选择1只「暗黑骑士 盖亚」怪兽展示给对方确认，之后洗切手卡。
function c2106266.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中是否存在至少1只符合条件的「暗黑骑士 盖亚」怪兽可展示。
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.costfilter1,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，引导玩家选择一张手卡用于给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡中选择1只满足条件的「暗黑骑士 盖亚」怪兽。
	local g=Duel.SelectMatchingCard(tp,c2106266.costfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡展示给对方玩家确认，以满足“给对方观看”的发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示手牌后洗切手卡，防止对方凭手牌顺序获得额外信息。
	Duel.ShuffleHand(tp)
end
-- 检索目标的过滤条件：等级为5且种族为龙族的怪兽，并且可以加入手卡。
function c2106266.thfilter1(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 第一个分支效果的目标设定：确认卡组中存在符合条件的龙族·5星怪兽，并登记本次操作的信息。
function c2106266.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1只符合条件的龙族·5星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示当前效果选择了“从卡组把1只龙族·5星怪兽加入手卡”这一分支。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁的处理将把1张卡从卡组加入手牌，供后续连锁中的应对效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 第一个分支效果的实际处理：从卡组选1只龙族·5星怪兽加入手卡，并让对方确认加入的卡。
function c2106266.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示从卡组选择要加入手牌的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1只符合条件的龙族·5星怪兽。
	local g=Duel.SelectMatchingCard(tp,c2106266.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认（检索完成后确认）。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- cost2的过滤条件：手卡中是等级5且龙族的怪兽卡，且当前不是公开状态，用于作为展示给对方确认的代价。
function c2106266.costfilter2(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
-- 第二个分支效果的发动代价：从手卡选择1只龙族·5星怪兽展示给对方确认，之后洗切手卡。
function c2106266.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中是否存在至少1只符合条件的龙族·5星怪兽可展示。
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.costfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，引导玩家选择一张手卡用于给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡中选择1只满足条件的龙族·5星怪兽。
	local g=Duel.SelectMatchingCard(tp,c2106266.costfilter2,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡展示给对方玩家确认，以满足“给对方观看”的发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示手牌后洗切手卡，防止对方凭手牌顺序获得额外信息。
	Duel.ShuffleHand(tp)
end
-- 检索目标的过滤条件：「暗黑骑士 盖亚」系列（0xbd）的怪兽卡，并且可以加入手卡。
function c2106266.thfilter2(c)
	return c:IsSetCard(0xbd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 第二个分支效果的目标设定：确认卡组中存在符合条件的「暗黑骑士 盖亚」怪兽，并登记本次操作的信息。
function c2106266.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1只符合条件的「暗黑骑士 盖亚」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示当前效果选择了“从卡组把1只「暗黑骑士 盖亚」怪兽加入手卡”这一分支。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁的处理将把1张卡从卡组加入手牌，供后续连锁中的应对效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 第二个分支效果的实际处理：从卡组选1只「暗黑骑士 盖亚」怪兽加入手卡，并让对方确认加入的卡。
function c2106266.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示从卡组选择要加入手牌的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1只符合条件的「暗黑骑士 盖亚」怪兽。
	local g=Duel.SelectMatchingCard(tp,c2106266.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认（检索完成后确认）。
		Duel.ConfirmCards(1-tp,g)
	end
end
