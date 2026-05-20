--新生代化石騎士 スカルポーン
-- 效果：
-- 岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「时间流」加入手卡。
function c86520461.initial_effect(c)
	-- 注册该卡片关联的卡片密码（59419719为「化石融合」）
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 注册融合召唤手续，素材为岩石族怪兽和4星以下的怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c86520461.matfilter,true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过「化石融合」的效果从额外卡组特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「时间流」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86520461,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,86520461)
	-- 将墓地的这张卡除外作为发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c86520461.thtg)
	e3:SetOperation(c86520461.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：等级大于0且在4星以下的怪兽
function c86520461.matfilter(c)
	return c:GetLevel()>0 and c:IsLevelBelow(4)
end
-- 检索卡片过滤条件：卡名为「时间流」且可以加入手卡
function c86520461.thfilter(c)
	return c:IsCode(85808813) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检查（Target阶段）
function c86520461.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「时间流」
	if chk==0 then return Duel.IsExistingMatchingCard(c86520461.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理（Operation阶段）：从卡组选择1张「时间流」加入手卡并给对方确认
function c86520461.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「时间流」
	local g=Duel.SelectMatchingCard(tp,c86520461.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
