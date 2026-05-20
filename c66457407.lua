--コピー・プラント
-- 效果：
-- 1回合1次，选择这张卡以外的场上1只植物族怪兽才能发动。这张卡的等级直到结束阶段时变成和选择的怪兽相同等级。
function c66457407.initial_effect(c)
	-- 1回合1次，选择这张卡以外的场上1只植物族怪兽才能发动。这张卡的等级直到结束阶段时变成和选择的怪兽相同等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66457407,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c66457407.lvtg)
	e1:SetOperation(c66457407.lvop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且有等级的植物族怪兽
function c66457407.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:GetLevel()>0
end
-- 效果发动的目标选择与合法性检测
function c66457407.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and c66457407.lvfilter(chkc) end
	-- 在发动阶段检查场上是否存在除自身以外的、满足过滤条件的植物族怪兽
	if chk==0 then return Duel.IsExistingTarget(c66457407.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只除自身以外的、满足过滤条件的植物族怪兽作为效果对象
	Duel.SelectTarget(tp,c66457407.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理，将自身等级变为与选择的对象怪兽相同
function c66457407.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的等级直到结束阶段时变成和选择的怪兽相同等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
