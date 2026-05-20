--ヴェンデット・ナイト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段丢弃1张手卡才能发动。从卡组把1只「复仇死者」怪兽加入手卡。
-- ②：自己的「复仇死者」怪兽的攻击破坏对方怪兽时，从自己墓地把1只「复仇死者」怪兽除外才能发动。那只怪兽向对方怪兽可以继续攻击。
function c76871889.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段丢弃1张手卡才能发动。从卡组把1只「复仇死者」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76871889,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,76871889)
	e2:SetCost(c76871889.thcost)
	e2:SetTarget(c76871889.thtg)
	e2:SetOperation(c76871889.thop)
	c:RegisterEffect(e2)
	-- ②：自己的「复仇死者」怪兽的攻击破坏对方怪兽时，从自己墓地把1只「复仇死者」怪兽除外才能发动。那只怪兽向对方怪兽可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76871889,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c76871889.atcon)
	e3:SetCost(c76871889.atcost)
	e3:SetOperation(c76871889.atop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价（丢弃1张手卡）的处理函数
function c76871889.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动代价检查阶段，检查手卡中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「复仇死者」怪兽的条件函数
function c76871889.thfilter(c)
	return c:IsSetCard(0x106) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检查函数
function c76871889.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在可检索的「复仇死者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76871889.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理函数（检索「复仇死者」怪兽）
function c76871889.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「复仇死者」怪兽
	local g=Duel.SelectMatchingCard(tp,c76871889.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件检查函数（自己的「复仇死者」怪兽战破对方怪兽，且该怪兽可以继续攻击）
function c76871889.atcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	e:SetLabelObject(ec)
	return ec:IsControler(tp) and ec:IsSetCard(0x106) and bc and bc:IsType(TYPE_MONSTER)
		and ec:IsChainAttackable(0,true) and ec:IsStatus(STATUS_OPPO_BATTLE)
end
-- 过滤墓地中可作为代价除外的「复仇死者」怪兽的条件函数
function c76871889.atcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价（从墓地除外1只「复仇死者」怪兽）的处理函数
function c76871889.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动代价检查阶段，检查自己墓地中是否存在可除外的「复仇死者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76871889.atcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择1张满足条件的「复仇死者」怪兽
	local g=Duel.SelectMatchingCard(tp,c76871889.atcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的墓地怪兽除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的实际处理函数（使该怪兽可以继续攻击，并限制不能直接攻击）
function c76871889.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	if not ec or not ec:IsRelateToBattle() then return end
	-- 使该怪兽可以再进行1次攻击
	Duel.ChainAttack()
	-- 那只怪兽向对方怪兽可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	ec:RegisterEffect(e1)
end
