--新生代化石マシン スカルバギー
-- 效果：
-- 自己墓地的岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
function c10040267.initial_effect(c)
	-- 建立与「化石融合」（卡号59419719）的卡名关联，用于特定检索或效果检测
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 设定融合素材：满足过滤条件函数matfilter的怪兽（自己墓地的岩石族怪兽）以及1只4星以下的怪兽
	aux.AddFusionProcFun2(c,c10040267.matfilter,aux.FilterBoolFunction(Card.IsLevelBelow,4),true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤限制，仅能通过化石融合或化石融合相关效果进行特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10040267,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设定发动条件为自身通过战斗将对方怪兽破坏并送去墓地
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c10040267.damtg)
	e2:SetOperation(c10040267.damop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10040267,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,10040267)
	-- 设定效果②的发动代价为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c10040267.thtg)
	e3:SetOperation(c10040267.thop)
	c:RegisterEffect(e3)
end
-- 融合素材中岩石族怪兽的过滤条件函数：必须是自己墓地的岩石族怪兽
function c10040267.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 效果①的发动效果目标（Target）处理：设置伤害的对象玩家和伤害数值
function c10040267.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为600
	Duel.SetTargetParam(600)
	-- 设置效果处理信息为给与对方玩家600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果①的效果处理（Operation）函数：对指定的玩家造成设定的伤害
function c10040267.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 用于检索的怪兽过滤条件函数：卡片效果文本有记述「化石融合」的怪兽，且可以加入手卡
function c10040267.thfilter(c)
	-- 检查卡片是否记述了「化石融合」、是否为怪兽卡以及是否可以加入手卡
	return aux.IsCodeListed(c,59419719) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动效果目标（Target）处理：检查卡组中是否存在可检索怪兽，并设定效果分类信息
function c10040267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10040267.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从自己卡组检索1只怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数：从卡组将1记述有「化石融合」的卡名记述的怪兽加入手卡
function c10040267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择加入手牌的卡片的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10040267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将所选卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片以确认
		Duel.ConfirmCards(1-tp,g)
	end
end
