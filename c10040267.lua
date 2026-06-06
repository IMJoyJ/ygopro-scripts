--新生代化石マシン スカルバギー
-- 效果：
-- 自己墓地的岩石族怪兽＋4星以下的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把有「化石融合」的卡名记述的1只怪兽加入手卡。
function c10040267.initial_effect(c)
	-- 在卡片的关系列表中添加「化石融合」（卡号59419719）
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 添加融合召唤的召唤手续：自己墓地的岩石族怪兽 ＋ 4星以下的怪兽
	aux.AddFusionProcFun2(c,c10040267.matfilter,aux.FilterBoolFunction(Card.IsLevelBelow,4),true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数（限制只能通过「化石融合」特召）
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10040267,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置效果触发条件：这张卡战斗破坏对方怪兽且自身和本次战斗有关
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
	-- 效果发动的Cost费用：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c10040267.thtg)
	e3:SetOperation(c10040267.thop)
	c:RegisterEffect(e3)
end
-- 融合素材岩石族怪兽的过滤条件（必须在自己墓地且由自己控制）
function c10040267.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 效果①的Target目标函数：设置目标玩家为对方，伤害数值为600，并注册伤害操作信息
function c10040267.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为伤害数值600
	Duel.SetTargetParam(600)
	-- 设置效果分类为伤害，目标为对方，伤害量为600
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果①的Operation处理函数：获取连锁的伤害目标与伤害数值，并给与对方伤害
function c10040267.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的对象玩家与伤害参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方基本分相应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤卡组中记述了「化石融合」且可以加入手牌的怪兽卡条件
function c10040267.thfilter(c)
	-- 判断卡片是否在卡面记述了「化石融合」，且是怪兽卡且能加入手牌
	return aux.IsCodeListed(c,59419719) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的Target目标函数：检查卡组中是否存在符合条件的怪兽，并注册检索手牌的操作信息
function c10040267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在记述了「化石融合」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10040267.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果分类为检索/加入手牌，目标为卡组中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation处理函数：从卡组将1只记述了「化石融合」的怪兽加入手牌，并向对方展示
function c10040267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的记述了「化石融合」的怪兽
	local g=Duel.SelectMatchingCard(tp,c10040267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入到玩家手牌中
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
