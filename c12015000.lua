--新生代化石竜 スカルガー
-- 效果：
-- 岩石族怪兽＋对方墓地的4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「化石融合」加入手卡。
function c12015000.initial_effect(c)
	-- 记录这张卡上记载着卡名「化石融合」（卡号59419719），使与记载卡名相关的检索/判定等效果能够正确识别。
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为「岩石族怪兽」1只 + 「对方墓地的4星以下的怪兽」1只（由matfilter判定），并允许使用代用品等特殊融合方式。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c12015000.matfilter,true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数：仅当以化石融合方式特召、或发动效果的卡是「化石融合」、或从额外卡组以外（如墓地）特召时允许，否则禁止从额外卡组特殊召唤。
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从卡组把1张「化石融合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12015000,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,12015000)
	-- 设置发动代价：将墓地中的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c12015000.thtg)
	e3:SetOperation(c12015000.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数：选择位于对方墓地、等级4以下、且作为融合素材时是怪兽卡的怪兽。
function c12015000.matfilter(c,fc)
	return c:IsFusionType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsLevelBelow(4) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-fc:GetControler())
end
-- 检索过滤函数：筛选卡名为「化石融合」（卡号59419719）且能够加入手卡的卡片。
function c12015000.thfilter(c)
	return c:IsCode(59419719) and c:IsAbleToHand()
end
-- ②效果的发动条件和处理信息设置：检查能否执行，并声明回手牌检索的操作信息。
function c12015000.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己卡组中存在至少1张可加入手卡的「化石融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(c12015000.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：从卡组将1张卡加入手牌，供后续效果联动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「化石融合」加入手牌，并向对方确认。
function c12015000.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张符合条件的「化石融合」。
	local g=Duel.SelectMatchingCard(tp,c12015000.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡送去持有者的手卡（加入手牌）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
