--新生代化石マシン スカルバギー
-- 效果：
-- 自己墓地的岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
function c10040267.initial_effect(c)
	-- 记录卡片上记载的「化石融合」卡名。
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，使用墓地的岩石族怪兽和4星以下的怪兽作为素材。
	aux.AddFusionProcFun2(c,c10040267.matfilter,aux.FilterBoolFunction(Card.IsLevelBelow,4),true)
	-- 创建效果，设置特殊召唤条件：只有通过“化石融合”的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为aux.FossilFusionLimit函数，该函数判断是否满足化石融合怪兽的特召限制。
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- 创建效果，描述：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
类别：伤害效果
触发条件：以战斗破坏对方怪兽
目标：对方玩家
操作：给予对方玩家600点伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10040267,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置诱发选发效果的condition，判断是否和本次战斗有关并且是攻击状态。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c10040267.damtg)
	e2:SetOperation(c10040267.damop)
	c:RegisterEffect(e2)
	-- 创建效果，描述：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
类别：将卡片送入手牌/检索
触发方式：起动效果
发动位置：墓地
次数限制：每回合一次
费用：将这张卡从场上除外
目标：从卡组检索一张有“化石融合”字样的怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10040267,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,10040267)
	-- 设置效果的cost，将这张卡从场上移除作为启动此效果的代价。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c10040267.thtg)
	e3:SetOperation(c10040267.thop)
	c:RegisterEffect(e3)
end
-- 定义一个过滤函数，用于筛选墓地的岩石族怪兽，并判断是否为当前玩家控制。
function c10040267.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 定义一个目标函数，用于确定伤害的目标和数值。
function c10040267.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置目标玩家为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置给予的伤害值为600。
	Duel.SetTargetParam(600)
	-- 设置连锁操作信息，表示这是一个伤害效果，目标是对方玩家，伤害值为600。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 定义一个操作函数，用于执行伤害效果。
function c10040267.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使用Duel.Damage函数对目标玩家造成指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 定义一个过滤函数，用于筛选卡组中带有“化石融合”字样的怪兽。
function c10040267.thfilter(c)
	-- 判断卡片是否记载有「化石融合」卡名、类型为怪兽并且可以加入手牌。
	return aux.IsCodeListed(c,59419719) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义一个目标函数，用于确定检索的目标卡片。
function c10040267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在卡组中是否存在满足过滤条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c10040267.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示这是一个将卡片送入手牌的效果，目标是当前玩家，从卡组检索一张卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义一个操作函数，用于执行检索效果。
function c10040267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息，要求选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择满足过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c10040267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片送入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认送入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
