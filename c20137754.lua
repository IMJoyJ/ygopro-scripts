--流星方界器デューザ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「方界」卡送去墓地。
-- ②：1回合1次，这张卡表侧表示存在的状态，怪兽被送去自己墓地的回合才能发动。这张卡的攻击力直到回合结束时上升自己墓地的怪兽种类×200。这个效果在对方回合也能发动。
function c20137754.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「方界」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20137754,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c20137754.tgtg)
	e1:SetOperation(c20137754.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡表侧表示存在的状态，怪兽被送去自己墓地的回合才能发动。这张卡的攻击力直到回合结束时上升自己墓地的怪兽种类×200。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20137754,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	e3:SetCondition(c20137754.atkcon)
	e3:SetTarget(c20137754.atktg)
	e3:SetOperation(c20137754.atkop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，这张卡表侧表示存在的状态，怪兽被送去自己墓地的回合才能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c20137754.regcon)
	e4:SetOperation(c20137754.regop)
	c:RegisterEffect(e4)
end
-- 检查卡是否为「方界」卡且可以被送去墓地。
function c20137754.tgfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToGrave()
end
-- 效果发动时确认卡组存在1张可送去墓地的「方界」卡，并登记进行从卡组送去墓地的操作信息。
function c20137754.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中有1张满足条件的「方界」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c20137754.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理时将把1张卡送去墓地的操作信息，供其他卡效果响应用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「方界」卡送去墓地。
function c20137754.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足「方界」条件的卡。
	local g=Duel.SelectMatchingCard(tp,c20137754.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：本回合已有怪兽被送去自己墓地，且当前时点允许（伤害步骤限制由aux.dscon处理）。
function c20137754.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(20137754)>0
		-- 限制在伤害步骤中只能在伤害计算前发动。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- ②效果发动时确认自己墓地存在怪兽，作为上升攻击力数值的依据。
function c20137754.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己墓地中有1只以上怪兽。
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)>0 end
end
-- ②效果处理：获取自己墓地所有怪兽，计算怪兽种类数×200，将攻击力上升该数值直到回合结束。
function c20137754.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己墓地的全部怪兽卡。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local val=g:GetClassCount(Card.GetCode)*200
	if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
		-- 这张卡的攻击力直到回合结束时上升自己墓地的怪兽种类×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断送入墓地的卡是否为己方怪兽且不是因返回手卡/卡组等理由送去墓地。
function c20137754.rfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_RETURN)
end
-- 当有己方怪兽被送去墓地时满足条件，触发标记记录。
function c20137754.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20137754.rfilter,1,nil,tp)
end
-- 给自己记录一个“本回合有怪兽被送去己方墓地”的标记，直到回合结束。
function c20137754.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20137754,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
