--無頼特急バトレイン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。给与对方500伤害。这个效果发动的回合，自己不能进行战斗阶段。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
function c24919805.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。给与对方500伤害。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24919805,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c24919805.damcost)
	e1:SetTarget(c24919805.damtg)
	e1:SetOperation(c24919805.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c24919805.regop)
	c:RegisterEffect(e2)
end
-- 检查是否处于主要阶段1，否则不能发动效果。
function c24919805.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否处于主要阶段1，否则不能发动效果。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 创建一个影响所有玩家的永续效果，使自己不能进入战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 设置伤害效果的目标玩家和伤害值。
function c24919805.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为500。
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为伤害效果。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行伤害效果。
function c24919805.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 注册墓地触发效果。
function c24919805.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建墓地触发效果，用于在结束阶段检索符合条件的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24919805,1))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,24919805)
	e1:SetTarget(c24919805.thtg)
	e1:SetOperation(c24919805.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 定义检索条件：10星、机械族、地属性、可加入手牌的怪兽。
function c24919805.filter(c)
	return c:IsLevel(10) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 设置检索效果的目标。
function c24919805.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24919805.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为加入手牌效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果。
function c24919805.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,c24919805.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
