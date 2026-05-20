--Emダメージ・ジャグラー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效并破坏。
-- ②：自己·对方的战斗阶段，把这张卡从手卡丢弃才能发动。这个回合，自己受到的战斗伤害只有1次变成0。
-- ③：把墓地的这张卡除外才能发动。从卡组把「娱乐法师 伤害杂耍人」以外的1只「娱乐法师」怪兽加入手卡。
function c68819554.initial_effect(c)
	-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68819554,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c68819554.negcon)
	e1:SetCost(c68819554.effcost)
	e1:SetTarget(c68819554.negtg)
	e1:SetOperation(c68819554.negop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段，把这张卡从手卡丢弃才能发动。这个回合，自己受到的战斗伤害只有1次变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68819554,1))  --"战斗伤害变成0"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c68819554.damcon)
	e2:SetCost(c68819554.effcost)
	e2:SetOperation(c68819554.damop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从卡组把「娱乐法师 伤害杂耍人」以外的1只「娱乐法师」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,68819554)
	-- 设置把墓地的这张卡除外作为发动代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c68819554.thtg)
	e3:SetOperation(c68819554.thop)
	c:RegisterEffect(e3)
end
-- ①号效果和②号效果的共同发动代价：把这张卡从手卡丢弃
function c68819554.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 作为发动代价，将手卡的这张卡丢弃并送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①号效果的发动条件：检查是否有可以被无效的、给与自己伤害的效果发动
function c68819554.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否可以被无效，且该效果是给与自己伤害的效果
	return Duel.IsChainNegatable(ev) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- ①号效果的发动准备：设置无效发动与破坏卡片的操作信息
function c68819554.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 如果发动的卡在场上且可以被破坏，设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①号效果的处理：使发动无效并破坏
function c68819554.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡在效果处理时仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：自己或对方的战斗阶段
function c68819554.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否处于战斗阶段（从战斗阶段开始到伤害步骤前）
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE_STEP)
end
-- ②号效果的处理：注册一个使本回合自己受到的战斗伤害只有1次变成0的效果
function c68819554.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的战斗伤害只有1次变成0。从卡组把「娱乐法师 伤害杂耍人」以外的1只「娱乐法师」怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	-- 在玩家身上注册该效果（使战斗伤害变成0）
	Duel.RegisterEffect(e1,tp)
end
-- ③号效果的过滤条件：卡组中「娱乐法师 伤害杂耍人」以外的1只「娱乐法师」怪兽
function c68819554.thfilter(c)
	return c:IsSetCard(0xc6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(68819554)
end
-- ③号效果的发动准备：检查卡组中是否存在符合条件的怪兽，并设置检索的操作信息
function c68819554.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张「娱乐法师 伤害杂耍人」以外的「娱乐法师」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68819554.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③号效果的处理：从卡组将1只「娱乐法师」怪兽加入手卡并给对方确认
function c68819554.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「娱乐法师」怪兽
	local g=Duel.SelectMatchingCard(tp,c68819554.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
