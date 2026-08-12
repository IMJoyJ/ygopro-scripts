--沈黙の剣
-- 效果：
-- ①：以自己场上1只「沉默剑士」怪兽为对象才能发动（这张卡的发动和效果不会被无效化）。那只自己怪兽攻击力·守备力上升1500，直到回合结束时不受对方的效果影响。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默剑士」怪兽加入手卡。
function c18563744.initial_effect(c)
	-- 以自己场上1只「沉默剑士」怪兽为对象才能发动（这张卡的发动和效果不会被无效化）。那只自己怪兽攻击力·守备力上升1500，直到回合结束时不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18563744,0))  --"攻击力·守备力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c18563744.target)
	e1:SetOperation(c18563744.activate)
	c:RegisterEffect(e1)
	-- 自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默剑士」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18563744,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 把这张卡除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c18563744.thtg)
	e2:SetOperation(c18563744.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否为「沉默剑士」且表侧表示。
function c18563744.filter(c)
	return c:IsSetCard(0xe7) and c:IsFaceup()
end
-- 设置效果的目标为己方场上的「沉默剑士」怪兽。
function c18563744.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18563744.filter(chkc) end
	-- 检查是否存在满足条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c18563744.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c18563744.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果的发动和应用，包括攻击力和守备力上升以及免疫效果。
function c18563744.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 使目标怪兽攻击力上升1500点。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1500)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 使目标怪兽在回合结束时免疫对方的效果。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(c18563744.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetOwnerPlayer(tp)
		tc:RegisterEffect(e3)
	end
end
-- 效果过滤函数，用于判断是否免疫对方的效果。
function c18563744.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 检索卡组中「沉默剑士」怪兽的过滤函数。
function c18563744.thfilter(c)
	return c:IsSetCard(0xe7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果的检索目标为卡组中的「沉默剑士」怪兽。
function c18563744.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「沉默剑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18563744.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张「沉默剑士」怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理卡组检索效果，选择并加入手牌。
function c18563744.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「沉默剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c18563744.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
