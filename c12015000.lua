--新生代化石竜 スカルガー
-- 效果：
-- 岩石族怪兽＋对方墓地的4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「化石融合」加入手卡。
function c12015000.initial_effect(c)
	-- 为卡片注册与「化石融合」相关的代码列表，用于后续效果判断
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 设置融合召唤条件：使用岩石族怪兽和对方墓地4星以下的怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c12015000.matfilter,true)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为化石融合相关限制函数，确保只能通过化石融合从额外卡组特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「化石融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 设置该卡具有贯穿伤害效果，使其攻击时可无视对方守备力
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12015000,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,12015000)
	-- 设置效果发动时需要将自身从墓地除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c12015000.thtg)
	e3:SetOperation(c12015000.thop)
	c:RegisterEffect(e3)
end
-- 定义融合素材过滤函数，用于筛选对方墓地中的4星以下怪兽
function c12015000.matfilter(c,fc)
	return c:IsFusionType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsLevelBelow(4) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-fc:GetControler())
end
-- 定义检索过滤函数，用于筛选卡组中的「化石融合」卡
function c12015000.thfilter(c)
	return c:IsCode(59419719) and c:IsAbleToHand()
end
-- 定义效果发动时的处理函数，用于设置效果目标
function c12015000.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中是否存在至少1张「化石融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c12015000.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张「化石融合」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果发动时的处理函数，用于执行效果操作
function c12015000.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张「化石融合」卡
	local g=Duel.SelectMatchingCard(tp,c12015000.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的「化石融合」卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
