--幻影騎士団ダスティローブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在场上攻击表示存在的场合，以场上1只暗属性怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽的攻击力·守备力直到对方回合结束时上升800。
-- ②：把墓地的这张卡除外才能发动。从卡组把「幻影骑士团 沾尘袍」以外的1张「幻影骑士团」卡加入手卡。
function c90432163.initial_effect(c)
	-- ①：这张卡在场上攻击表示存在的场合，以场上1只暗属性怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽的攻击力·守备力直到对方回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90432163,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,90432163)
	e1:SetCondition(c90432163.condition)
	e1:SetTarget(c90432163.target)
	e1:SetOperation(c90432163.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把「幻影骑士团 沾尘袍」以外的1张「幻影骑士团」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90432163,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,90432164)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c90432163.thtg)
	e2:SetOperation(c90432163.thop)
	c:RegisterEffect(e2)
end
-- 发动条件：这张卡在场上表侧攻击表示存在
function c90432163.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤条件：场上表侧表示的暗属性怪兽
function c90432163.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果1的发动准备：检查并选择场上1只表侧表示的暗属性怪兽作为对象
function c90432163.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c90432163.filter(chkc) end
	-- 在发动阶段，检查场上是否存在至少1只满足条件的暗属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c90432163.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的暗属性怪兽作为效果对象
	Duel.SelectTarget(tp,c90432163.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果1的处理：将自身变为守备表示，并使目标怪兽的攻击力·守备力直到对方回合结束时上升800
function c90432163.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否仍适用效果，并将其变为表侧守备表示，若变更失败则不继续处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)==0 then return end
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽的攻击力·守备力直到对方回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：卡组中「幻影骑士团 沾尘袍」以外的「幻影骑士团」卡片
function c90432163.thfilter(c)
	return c:IsSetCard(0x10db) and not c:IsCode(90432163) and c:IsAbleToHand()
end
-- 效果2的发动准备：检查卡组中是否存在可检索的卡片并设置操作信息
function c90432163.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在满足条件的「幻影骑士团」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c90432163.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2的处理：从卡组选择1张「幻影骑士团」卡片加入手卡并给对方确认
function c90432163.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c90432163.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
