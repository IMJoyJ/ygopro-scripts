--ワンダー・クローバー
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽，从手卡把1只4星的植物族怪兽送去墓地发动。选择怪兽在同1次的战斗阶段中可以作2次攻击。这张卡发动的回合，自己场上存在的其他怪兽不能攻击宣言。
function c38568567.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽，从手卡把1只4星的植物族怪兽送去墓地发动。选择怪兽在同1次的战斗阶段中可以作2次攻击。这张卡发动的回合，自己场上存在的其他怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c38568567.condition)
	e1:SetCost(c38568567.cost)
	e1:SetTarget(c38568567.target)
	e1:SetOperation(c38568567.operation)
	c:RegisterEffect(e1)
end
-- 定义卡的发动条件：当前回合玩家能够进入战斗阶段时才能发动。
function c38568567.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否能够进入战斗阶段，作为发动条件判断。
	return Duel.IsAbleToEnterBP()
end
-- 定义作为cost的卡的过滤条件：手牌中等级为4、种族为植物族、且可以作为cost送去墓地的怪兽。
function c38568567.cfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_PLANT) and c:IsAbleToGraveAsCost()
end
-- 定义发动cost的处理流程：先检查是否存在满足条件的卡，若存在则提示玩家选择一张手牌的4星植物族怪兽送去墓地作为cost，并设置标记为1表示已支付cost。
function c38568567.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检测：若不存在满足条件的4星植物族手卡，则不能发动（返回false）。
	if chk==0 then return Duel.IsExistingMatchingCard(c38568567.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择一张满足条件的4星植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,c38568567.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽卡作为cost送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(1)
end
-- 定义效果对象的选择条件：怪兽必须是表侧表示，且没有受到额外攻击次数效果的影响。
function c38568567.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 定义发动时的目标选择及誓约效果注册：选择自己场上一只表侧表示怪兽作为对象；若已支付cost，则同时给己方场上其他怪兽附加本回合不能攻击的誓约效果。
function c38568567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38568567.filter(chkc) end
	-- 目标检测：若自己场上不存在满足条件的表侧表示怪兽，则不能发动（返回false）。
	if chk==0 then return Duel.IsExistingTarget(c38568567.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择一只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c38568567.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetLabel()==1 then
		-- 这张卡发动的回合，自己场上存在的其他怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c38568567.ftarget)
		e1:SetLabel(g:GetFirst():GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“其他怪兽不能攻击宣言”的誓约效果注册到己方场上，持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
		e:SetLabel(0)
	end
end
-- 效果处理时，若选择的对象仍然与效果关联，则给该对象附加攻击次数+1的效果，使其在同一战斗阶段中可以作2次攻击。
function c38568567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 选择怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 用于判定怪兽是否为目标怪兽；除目标怪兽外，己方场上其他怪兽都会受到不能攻击宣言的誓约效果影响。
function c38568567.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
