--走破するガイア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方在战斗阶段中不能把效果发动。
-- ②：可以从以下效果选择1个发动。
-- ●把手卡1只「暗黑骑士 盖亚」怪兽给对方观看才能发动。从卡组把1只龙族·5星怪兽加入手卡。
-- ●把手卡1只龙族·5星怪兽给对方观看才能发动。从卡组把1只「暗黑骑士 盖亚」怪兽加入手卡。
function c2106266.initial_effect(c)
	-- 记录此卡与「龙骑士 盖亚」的关联
	aux.AddCodeList(c,66889139)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 只要自己的怪兽区域有「龙骑士 盖亚」存在，对方在战斗阶段中不能把效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(1)
	e1:SetCondition(c2106266.actcon)
	c:RegisterEffect(e1)
	-- 可以从以下效果选择1个发动。●把手卡1只「暗黑骑士 盖亚」怪兽给对方观看才能发动。从卡组把1只龙族·5星怪兽加入手卡。
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
-- 过滤函数，用于判断场上是否存在「龙骑士 盖亚」
function c2106266.actfilter(c)
	return c:IsFaceup() and c:IsCode(66889139)
end
-- 判断条件函数，用于判断是否满足①效果的发动条件
function c2106266.actcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	local tp=e:GetHandlerPlayer()
	-- 判断是否在战斗阶段且场上存在「龙骑士 盖亚」
	return Duel.IsExistingMatchingCard(c2106266.actfilter,tp,LOCATION_MZONE,0,1,nil) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤函数，用于判断手卡中是否存在「暗黑骑士 盖亚」怪兽
function c2106266.costfilter1(c)
	return c:IsSetCard(0xbd) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果处理函数，用于支付②效果的代价
function c2106266.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在「暗黑骑士 盖亚」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.costfilter1,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手卡中的「暗黑骑士 盖亚」怪兽
	local g=Duel.SelectMatchingCard(tp,c2106266.costfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将手卡洗牌
	Duel.ShuffleHand(tp)
end
-- 过滤函数，用于判断卡组中是否存在龙族·5星怪兽
function c2106266.thfilter1(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果处理函数，用于设置②效果①的发动目标
function c2106266.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在龙族·5星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息，准备将龙族·5星怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行②效果①的效果
function c2106266.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张龙族·5星怪兽
	local g=Duel.SelectMatchingCard(tp,c2106266.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的龙族·5星怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断手卡中是否存在龙族·5星怪兽
function c2106266.costfilter2(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
-- 效果处理函数，用于支付②效果②的代价
function c2106266.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在龙族·5星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.costfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手卡中的龙族·5星怪兽
	local g=Duel.SelectMatchingCard(tp,c2106266.costfilter2,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将手卡洗牌
	Duel.ShuffleHand(tp)
end
-- 过滤函数，用于判断卡组中是否存在「暗黑骑士 盖亚」怪兽
function c2106266.thfilter2(c)
	return c:IsSetCard(0xbd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理函数，用于设置②效果②的发动目标
function c2106266.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「暗黑骑士 盖亚」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2106266.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息，准备将「暗黑骑士 盖亚」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行②效果②的效果
function c2106266.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「暗黑骑士 盖亚」怪兽
	local g=Duel.SelectMatchingCard(tp,c2106266.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「暗黑骑士 盖亚」怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
