--武神器－ヤツカ
-- 效果：
-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。这个效果发动的回合，选择的怪兽以外的怪兽不能攻击。
function c86868952.initial_effect(c)
	-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。这个效果发动的回合，选择的怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86868952,0))  --"2次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c86868952.condition)
	e1:SetCost(c86868952.cost)
	e1:SetTarget(c86868952.target)
	e1:SetOperation(c86868952.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：判断当前是否为自己的主要阶段1（通过能否进入战斗阶段来判定）
function c86868952.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否可以进入战斗阶段（用于判定当前是否为主要阶段1）
	return Duel.IsAbleToEnterBP()
end
-- 发动代价：把这张卡从手卡送去墓地
function c86868952.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的名字带有「武神」且未拥有追加攻击效果的怪兽
function c86868952.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 发动准备：选择自己场上1只名字带有「武神」的怪兽作为对象，并注册“其他怪兽不能攻击”的限制效果
function c86868952.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86868952.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的「武神」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c86868952.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「武神」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86868952.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 这个效果发动的回合，选择的怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c86868952.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该不能攻击的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤不能攻击的怪兽：排除当前选择的对象怪兽（即除对象怪兽以外的怪兽都不能攻击）
function c86868952.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果处理：使选择的对象怪兽在同一次战斗阶段中可以作2次攻击
function c86868952.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
