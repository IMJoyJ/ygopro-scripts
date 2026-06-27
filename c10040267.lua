--新生代化石マシン スカルバギー
-- 效果：
-- 自己墓地的岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
function c10040267.initial_effect(c)
	-- 声明关联的「化石融合」卡片
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 融合素材：自己墓地的岩石族怪兽＋4星以下的怪兽
	aux.AddFusionProcFun2(c,c10040267.matfilter,aux.FilterBoolFunction(Card.IsLevelBelow,4),true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制使用「化石融合」的效果才能特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
类别：伤害效果
触发条件：以战斗破坏对方怪兽
目标：对方玩家
操作：给予对方玩家600点伤害。
	-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10040267,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 限制必须是战斗破坏对方怪兽的场合才能发动
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c10040267.damtg)
	e2:SetOperation(c10040267.damop)
	c:RegisterEffect(e2)
类别：将卡片送入手牌/检索
触发方式：起动效果
发动位置：墓地
次数限制：每回合一次
费用：将这张卡从场上除外
目标：从卡组检索一张有“化石融合”字样的怪兽。
	-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10040267,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,10040267)
	-- 检索效果的Cost：将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c10040267.thtg)
	e3:SetOperation(c10040267.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤：墓地中的岩石族怪兽
function c10040267.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 伤害效果的条件锁定与声明
function c10040267.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害承受者为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害量为600点
	Duel.SetTargetParam(600)
	-- 声明伤害对方玩家的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 伤害效果的实际操作
function c10040267.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取设置的目标玩家以及伤害量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对对方玩家造成600点效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤记述有「化石融合」的怪兽卡片
function c10040267.thfilter(c)
	-- 检查卡片中是否记述有「化石融合」的卡名
	return aux.IsCodeListed(c,59419719) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的条件检查与锁定
function c10040267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在记述有「化石融合」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10040267.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 声明检索并加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际操作
function c10040267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10040267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
