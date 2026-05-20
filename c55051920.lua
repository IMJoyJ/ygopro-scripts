--オルフェゴール・コア
-- 效果：
-- ①：1回合1次，从自己的场上·墓地把1只怪兽除外，以「自奏圣乐的延音」以外的自己场上1张「自奏圣乐」卡或者「星遗物」卡为对象才能发动。这个回合，那张卡不会成为效果的对象。
-- ②：这张卡以外的自己场上的「自奏圣乐」卡或者「星遗物」卡被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
function c55051920.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己的场上·墓地把1只怪兽除外，以「自奏圣乐的延音」以外的自己场上1张「自奏圣乐」卡或者「星遗物」卡为对象才能发动。这个回合，那张卡不会成为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55051920,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(c55051920.tgcost)
	e2:SetTarget(c55051920.tgtg)
	e2:SetOperation(c55051920.tgop)
	c:RegisterEffect(e2)
	-- ②：这张卡以外的自己场上的「自奏圣乐」卡或者「星遗物」卡被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c55051920.reptg)
	e3:SetValue(c55051920.repval)
	e3:SetOperation(c55051920.repop)
	c:RegisterEffect(e3)
end
-- 过滤作为除外代价的怪兽：必须是怪兽卡、可以作为代价除外，且场上存在至少1张可以作为效果对象的、除自身以外的「自奏圣乐」或「星遗物」卡
function c55051920.costfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查场上是否存在至少1张可以作为效果对象的、除自身（作为代价除外的卡）以外的「自奏圣乐」或「星遗物」卡
		and Duel.IsExistingTarget(c55051920.tgfilter,tp,LOCATION_ONFIELD,0,1,c)
end
-- 过滤效果对象：必须是表侧表示的「自奏圣乐」或「星遗物」卡，且不能是「自奏圣乐的延音」自身
function c55051920.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfe,0x11b) and not c:IsCode(55051920)
end
-- 效果①的代价处理：从自己的场上或墓地选择1只怪兽除外
function c55051920.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己的墓地或怪兽区是否存在满足代价过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55051920.costfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己的墓地或怪兽区选择1张满足条件的怪兽
	local cg=Duel.SelectMatchingCard(tp,c55051920.costfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 效果①的对象选择与发动准备：在场上选择1张满足条件的卡作为对象
function c55051920.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c55051920.tgfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1张自己场上的「自奏圣乐」卡或「星遗物」卡作为效果对象
	Duel.SelectTarget(tp,c55051920.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 效果①的效果处理：使作为对象的卡在这个回合不会成为效果的对象
function c55051920.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那张卡不会成为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤被破坏的卡：必须是自己场上表侧表示的「自奏圣乐」或「星遗物」卡，且因战斗或效果被破坏（排除代替破坏的情况）
function c55051920.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xfe,0x11b) and c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的条件判定：检查自身是否未处于确定破坏状态，且被破坏的卡中是否存在满足条件的卡
function c55051920.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c55051920.repfilter,1,e:GetHandler(),tp) end
	-- 询问玩家是否使用代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定哪些卡适用代替破坏：返回满足过滤条件的被破坏卡片
function c55051920.repval(e,c)
	return c55051920.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的具体执行：将这张卡送去墓地
function c55051920.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡（自奏圣乐的延音）送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
