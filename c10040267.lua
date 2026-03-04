--新生代化石マシン スカルバギー
-- 效果：
-- 自己墓地的岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
function c10040267.initial_effect(c)
	-- 为卡片注册“有化石融合记述”的卡片代码列表，用于后续效果判断
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 设置融合召唤的素材条件：一张岩石族怪兽和一张4星以下的怪兽
	aux.AddFusionProcFun2(c,c10040267.matfilter,aux.FilterBoolFunction(Card.IsLevelBelow,4),true)
	-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡特殊召唤的条件为化石融合限定
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10040267,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置该效果的发动条件为：与对方怪兽战斗并破坏对方怪兽
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
	-- 设置该效果的发动费用为：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c10040267.thtg)
	e3:SetOperation(c10040267.thop)
	c:RegisterEffect(e3)
end
-- 定义融合召唤的素材过滤函数，用于判断墓地中的岩石族怪兽
function c10040267.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 定义伤害效果的目标设定函数，用于设置伤害对象和伤害值
function c10040267.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置本次连锁的伤害值为600
	Duel.SetTargetParam(600)
	-- 设置本次连锁的操作信息为对对方造成600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 定义伤害效果的处理函数，用于实际造成伤害
function c10040267.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 定义检索效果的过滤函数，用于筛选卡组中具有化石融合记述的怪兽
function c10040267.thfilter(c)
	-- 返回满足条件的卡：具有化石融合记述、类型为怪兽、可以送入手牌
	return aux.IsCodeListed(c,59419719) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义检索效果的目标设定函数，用于判断是否可以发动检索效果
function c10040267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10040267.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为从卡组将1张符合条件的卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的处理函数，用于实际执行检索和送入手牌操作
function c10040267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要送入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c10040267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
