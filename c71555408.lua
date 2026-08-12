--剛鬼アイアン・クロー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「刚鬼」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只自己怪兽直到回合结束时攻击力上升500，不受对方的效果影响。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 铁爪手」以外的1张「刚鬼」卡加入手卡。
function c71555408.initial_effect(c)
	-- ①：自己的「刚鬼」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只自己怪兽直到回合结束时攻击力上升500，不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71555408,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,71555408)
	e1:SetCondition(c71555408.atkcon)
	e1:SetCost(c71555408.atkcost)
	e1:SetOperation(c71555408.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 铁爪手」以外的1张「刚鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71555408,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,71555409)
	e2:SetCondition(c71555408.thcon)
	e2:SetTarget(c71555408.thtg)
	e2:SetOperation(c71555408.thop)
	c:RegisterEffect(e2)
end
-- 判断是否处于伤害步骤开始时至伤害计算前，且自己场上的「刚鬼」怪兽正与对方怪兽进行战斗
function c71555408.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	-- 判断当前是否为伤害步骤，且尚未进行伤害计算
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(a)
	return a and a:IsFaceup() and a:IsControler(tp) and a:IsSetCard(0xfc) and a:IsRelateToBattle()
		and d and d:IsControler(1-tp)
end
-- 检查并执行发动代价：将手牌的这张卡送去墓地
function c71555408.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：使进行战斗的自己怪兽直到回合结束时攻击力上升500，且不受对方的效果影响
function c71555408.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetLabelObject()
	if not a or not a:IsRelateToBattle() then return end
	if a:IsFaceup() then
		-- 那只自己怪兽直到回合结束时攻击力上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		a:RegisterEffect(e1)
		-- 不受对方的效果影响
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c71555408.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetOwnerPlayer(tp)
		a:RegisterEffect(e2)
	end
end
-- 过滤不受影响的效果，限定为对方玩家拥有的卡片效果
function c71555408.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 检查此卡是否是从场上送去墓地
function c71555408.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中除「刚鬼 铁爪手」以外的「刚鬼」卡片
function c71555408.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(71555408) and c:IsAbleToHand()
end
-- 检查卡组中是否存在可检索的卡，并设置将卡加入手牌的操作信息
function c71555408.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「刚鬼 铁爪手」以外的「刚鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71555408.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理是将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「刚鬼」卡加入手牌并给对方确认
function c71555408.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c71555408.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
