--新生代化石マシン スカルバギー
-- 效果：
-- 自己墓地的岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
function c10040267.initial_effect(c)
	-- 在卡片的关联卡片列表中注册「化石融合」（卡号59419719）
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，需要以自己墓地的岩石族怪兽和4星以下的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c10040267.matfilter,aux.FilterBoolFunction(Card.IsLevelBelow,4),true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为化石融合怪兽特召限制函数
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
	-- 设置效果的发动条件：这张卡战斗破坏对方怪兽
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
	-- 设置效果的发动费用：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c10040267.thtg)
	e3:SetOperation(c10040267.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：自己墓地的岩石族怪兽
function c10040267.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 伤害效果的发动准备：设置目标玩家为对方玩家，伤害数值为600，并向系统注册伤害的操作信息
function c10040267.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数（伤害数值）为600
	Duel.SetTargetParam(600)
	-- 向系统注册当前连锁的操作信息：效果分类为伤害，目标玩家为对方玩家，数值600
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 伤害效果的执行：获取目标玩家和伤害参数，给予对方玩家600点效果伤害
function c10040267.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁中的目标玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与玩家效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 检索卡片的过滤条件：有「化石融合」卡名记述的怪兽，且能加入手卡
function c10040267.thfilter(c)
	-- 过滤条件：效果文本有「化石融合」卡名记述、是怪兽卡、且可以加入手卡
	return aux.IsCodeListed(c,59419719) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在满足条件的卡，并向系统注册加入手牌的操作信息
function c10040267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足 thfilter 过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10040267.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统注册当前连锁的操作信息：效果分类为加入手牌，数量1，操作玩家为自己，操作范围为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1张有「化石融合」卡名记述的怪兽加入手卡，并向对方展示以进行确认
function c10040267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在提示框显示“请选择要加入手牌的卡”的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足 thfilter 过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c10040267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 以效果原因将所选卡片送入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片向对方展示以进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
