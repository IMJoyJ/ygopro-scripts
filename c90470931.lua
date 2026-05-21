--鬼神の連撃
-- 效果：
-- 选择自己场上表侧表示存在的1只超量怪兽，把那些超量素材全部取除发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
function c90470931.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只超量怪兽，把那些超量素材全部取除发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c90470931.condition)
	e1:SetCost(c90470931.cost)
	e1:SetTarget(c90470931.target)
	e1:SetOperation(c90470931.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查当前回合玩家是否能进入战斗阶段。
function c90470931.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 代价处理：设置Label为1，用于在target中标记需要检查并支付取除超量素材的代价。
function c90470931.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤条件：自己场上表侧表示、未拥有追加攻击效果的超量怪兽（若需要检查代价，则该怪兽必须拥有超量素材）。
function c90470931.filter(c,cst)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) and (not cst or c:GetOverlayCount()~=0)
end
-- 靶向与代价处理：选择1只超量怪兽作为对象，并取除其全部超量素材作为发动代价。
function c90470931.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local chkcost=e:GetLabel()==1 and true or false
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c90470931.filter(chkc,chkcost) end
	if chk==0 then
		e:SetLabel(0)
		-- 检查自己场上是否存在符合条件的表侧表示超量怪兽。
		return Duel.IsExistingTarget(c90470931.filter,tp,LOCATION_MZONE,0,1,nil,chkcost)
	end
	e:SetLabel(0)
	-- 给玩家发送提示信息：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的表侧表示超量怪兽作为效果的对象。
	local tc=Duel.SelectTarget(tp,c90470931.filter,tp,LOCATION_MZONE,0,1,1,nil,chkcost):GetFirst()
	if chkcost then
		tc:RemoveOverlayCard(tp,tc:GetOverlayCount(),tc:GetOverlayCount(),REASON_COST)
	end
end
-- 效果处理：给选择的怪兽赋予在同1次战斗阶段中可以作2次攻击的效果。
function c90470931.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
