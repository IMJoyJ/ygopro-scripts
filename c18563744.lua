--沈黙の剣
-- 效果：
-- ①：以自己场上1只「沉默剑士」怪兽为对象才能发动（这张卡的发动和效果不会被无效化）。那只自己怪兽攻击力·守备力上升1500，直到回合结束时不受对方的效果影响。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默剑士」怪兽加入手卡。
function c18563744.initial_effect(c)
	-- ①：以自己场上1只「沉默剑士」怪兽为对象才能发动（这张卡的发动和效果不会被无效化）。那只自己怪兽攻击力·守备力上升1500，直到回合结束时不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18563744,0))  --"攻击力·守备力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果在伤害步骤内的发动限制：只能在伤害计算前发动（伤害步骤条件限制）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c18563744.target)
	e1:SetOperation(c18563744.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默剑士」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18563744,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动代价为将墓地里的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c18563744.thtg)
	e2:SetOperation(c18563744.thop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：表侧表示的「沉默剑士」怪兽。
function c18563744.filter(c)
	return c:IsSetCard(0xe7) and c:IsFaceup()
end
-- 取对象处理：选择自己场上1只表侧表示的「沉默剑士」怪兽作为对象。
function c18563744.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18563744.filter(chkc) end
	-- 发动时检查自己场上是否存在表侧表示的「沉默剑士」怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c18563744.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的「沉默剑士」怪兽作为效果对象。
	Duel.SelectTarget(tp,c18563744.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使对象怪兽攻击力·守备力上升1500，并且直到回合结束时不受对方的效果影响。
function c18563744.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得取对象效果所选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只自己怪兽攻击力·守备力上升1500（攻击力部分）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1500)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 直到回合结束时不受对方的效果影响。
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
-- 判断免疫条件：与自己效果持有者不同（对方）的效果无法适用。
function c18563744.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 定义检索筛选条件：卡组中的「沉默剑士」怪兽且能够加入手卡。
function c18563744.thfilter(c)
	return c:IsSetCard(0xe7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 目标处理：检查卡组是否存在符合条件的「沉默剑士」怪兽，并设置检索回手牌的操作信息。
function c18563744.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在符合条件的「沉默剑士」怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18563744.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只「沉默剑士」怪兽加入手牌，并让对方确认。
function c18563744.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「沉默剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c18563744.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
