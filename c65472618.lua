--魔装戦士 ドラゴディウス
-- 效果：
-- ←2 【灵摆】 2→
-- ①：自己怪兽和对方的表侧表示怪兽进行战斗的伤害步骤开始时丢弃1张手卡才能发动。那只进行战斗的对方怪兽的攻击力·守备力变成一半。
-- 【怪兽效果】
-- ①：自己的怪兽区域的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。这个回合的结束阶段，从卡组把「魔装战士 龙天」以外的攻击力2000以下的1只战士族或者魔法师族怪兽加入手卡。
function c65472618.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：自己怪兽和对方的表侧表示怪兽进行战斗的伤害步骤开始时丢弃1张手卡才能发动。那只进行战斗的对方怪兽的攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c65472618.atkcon)
	e2:SetCost(c65472618.atkcost)
	e2:SetOperation(c65472618.atkop)
	c:RegisterEffect(e2)
	-- ①：自己的怪兽区域的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。这个回合的结束阶段，从卡组把「魔装战士 龙天」以外的攻击力2000以下的1只战士族或者魔法师族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c65472618.regcon)
	e3:SetOperation(c65472618.regop)
	c:RegisterEffect(e3)
end
-- 灵摆效果发动条件判断：自己怪兽与对方表侧表示怪兽战斗的伤害步骤开始时
function c65472618.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc=tc end
	e:SetLabelObject(bc)
	return bc:IsFaceup()
end
-- 灵摆效果发动代价：丢弃1张手牌
function c65472618.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 灵摆效果处理：使进行战斗的对方怪兽的攻击力与守备力变成一半
function c65472618.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		-- 那只进行战斗的对方怪兽的攻击力·守备力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(bc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(bc:GetDefense()/2))
		bc:RegisterEffect(e2)
	end
end
-- 怪兽效果发动条件判断：自己的怪兽区域的这张卡被对方怪兽的攻击或者对方的效果破坏
function c65472618.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 判断是否因对方的效果破坏，或者被对方怪兽攻击破坏
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- 怪兽效果处理：注册一个在回合结束阶段发动的效果
function c65472618.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从卡组把「魔装战士 龙天」以外的攻击力2000以下的1只战士族或者魔法师族怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c65472618.thcon)
	e1:SetOperation(c65472618.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段发动的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：卡组中「魔装战士 龙天」以外的攻击力2000以下的战士族或魔法师族怪兽
function c65472618.thfilter(c)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) and not c:IsCode(65472618) and c:IsAbleToHand()
end
-- 结束阶段检索效果的发动条件：卡组中存在满足条件的怪兽
function c65472618.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在满足检索条件的怪兽
	return Duel.IsExistingMatchingCard(c65472618.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 结束阶段检索效果的处理：从卡组将满足条件的怪兽加入手卡
function c65472618.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送卡片提示，显示「魔装战士 龙天」的效果发动动画
	Duel.Hint(HINT_CARD,0,65472618)
	-- 发送提示信息，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c65472618.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
