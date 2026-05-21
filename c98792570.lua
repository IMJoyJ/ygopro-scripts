--受け継がれる力
-- 效果：
-- 把自己场上1只怪兽送去墓地。选择自己场上1只怪兽。选择的那只怪兽的攻击力，在发动回合的结束阶段前上升送去墓地的那张卡的攻击力的数值。
function c98792570.initial_effect(c)
	-- 把自己场上1只怪兽送去墓地。选择自己场上1只怪兽。选择的那只怪兽的攻击力，在发动回合的结束阶段前上升送去墓地的那张卡的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c98792570.cost)
	e1:SetTarget(c98792570.target)
	e1:SetOperation(c98792570.activate)
	c:RegisterEffect(e1)
end
-- 暂存标记以在target中判断是否由cost流程调用（防止在非发动时进行非法检测）。
function c98792570.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：用于筛选可以作为送去墓地代价的怪兽（其原本攻击力大于0，且场上还存在其他可以作为效果对象的表侧表示怪兽）。
function c98792570.cfilter(c,e,tp)
	-- 检查该怪兽的原本攻击力是否大于0，且自己场上是否存在除该卡以外的至少1只表侧表示怪兽作为效果对象。
	return c:GetTextAttack()>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c)
end
-- 效果发动时的处理：检查发动条件、支付送去墓地的代价、记录送去墓地怪兽的攻击力，并选择自己场上1只表侧表示怪兽作为效果对象。
function c98792570.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在满足送墓代价过滤条件的怪兽。
		return Duel.IsExistingMatchingCard(c98792570.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足送墓代价过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c98792570.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选择的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	-- 将送去墓地怪兽的原本攻击力数值保存为效果参数，以便在效果处理时读取。
	Duel.SetTargetParam(g:GetFirst():GetTextAttack())
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：使选择的怪兽攻击力上升送去墓地怪兽的攻击力数值，该效果持续到回合结束。
function c98792570.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的那只怪兽的攻击力，在发动回合的结束阶段前上升送去墓地的那张卡的攻击力的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 设置攻击力上升的数值为之前保存的送去墓地怪兽的攻击力数值。
		e1:SetValue(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
