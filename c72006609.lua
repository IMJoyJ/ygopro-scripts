--明星の機械騎士
-- 效果：
-- 包含「机界骑士」怪兽的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，从手卡丢弃1只「机界骑士」怪兽或者1张「星遗物」卡才能发动。从卡组把1张「星遗物」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己的「机界骑士」怪兽不会被和与那自身纵列不同纵列的怪兽的战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
function c72006609.initial_effect(c)
	-- 设置连接召唤的手续，需要2只怪兽作为素材，且必须满足lcheck过滤条件（包含「机界骑士」怪兽）。
	aux.AddLinkProcedure(c,nil,2,2,c72006609.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤成功的场合，从手卡丢弃1只「机界骑士」怪兽或者1张「星遗物」卡才能发动。从卡组把1张「星遗物」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72006609,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,72006609)
	e1:SetCondition(c72006609.thcon)
	e1:SetCost(c72006609.thcost)
	e1:SetTarget(c72006609.thtg)
	e1:SetOperation(c72006609.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己的「机界骑士」怪兽不会被和与那自身纵列不同纵列的怪兽的战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置永续效果的影响对象为自己场上的「机界骑士」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10c))
	e2:SetValue(c72006609.tglimit)
	c:RegisterEffect(e2)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置伤害免除效果的影响对象为自己场上的「机界骑士」怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10c))
	e3:SetValue(c72006609.tglimit)
	c:RegisterEffect(e3)
end
-- 连接素材的过滤条件：素材组中必须存在至少1只「机界骑士」怪兽。
function c72006609.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x10c)
end
-- 效果①的发动条件：这张卡连接召唤成功。
function c72006609.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：用于筛选手牌中可作为发动代价丢弃的「机界骑士」怪兽或「星遗物」卡。
function c72006609.costfilter(c)
	return ((c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe)) and c:IsDiscardable()
end
-- 效果①的发动代价：从手牌丢弃1张「机界骑士」怪兽或「星遗物」卡。
function c72006609.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查手牌中是否存在可作为代价丢弃的「机界骑士」怪兽或「星遗物」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c72006609.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌中的「机界骑士」怪兽或「星遗物」卡作为发动代价。
	Duel.DiscardHand(tp,c72006609.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 过滤函数：用于筛选卡组中可加入手牌的「星遗物」卡。
function c72006609.thfilter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组中是否存在可检索的「星遗物」卡，并设置操作信息。
function c72006609.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查卡组中是否存在可检索的「星遗物」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c72006609.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果包含“从卡组将1张卡加入手牌”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张「星遗物」卡加入手牌，并给对方确认。
function c72006609.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在屏幕上显示提示信息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「星遗物」卡。
	local g=Duel.SelectMatchingCard(tp,c72006609.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制条件函数：判断进行战斗的敌方怪兽是否不处于与自身相同的纵列。
function c72006609.tglimit(e,c)
	return c and not c:GetBattleTarget():GetColumnGroup():IsContains(c)
end
