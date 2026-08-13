--サイバネティック・ゾーン
-- 效果：
-- 选择自己场上表侧表示存在的1只机械族的融合怪兽，直到发动回合的结束阶段时从游戏中除外。从游戏中除外的怪兽回到场上时，那只怪兽的攻击力变成2倍。下次的自己回合的准备阶段时，成为这张卡的对象的1只机械族的融合怪兽破坏。
function c47295267.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只机械族的融合怪兽，直到发动回合的结束阶段时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47295267.target)
	e1:SetOperation(c47295267.operation)
	c:RegisterEffect(e1)
end
-- 定义可选对象的过滤条件：表侧表示、机械族、融合怪兽、可以被除外。
function c47295267.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
end
-- 目标选择函数：检查是否存在符合条件的对象；若存在则让玩家选择1只自己场上的表侧表示机械族融合怪兽，并将其登记为效果对象，同时宣告除外操作。
function c47295267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47295267.filter(chkc) end
	-- 发动时检查：自己场上是否存在至少1只满足过滤条件的表侧表示机械族融合怪兽。
	if chk==0 then return Duel.IsExistingTarget(c47295267.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只符合条件的机械族融合怪兽作为效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c47295267.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将选择的对象登记为除外处理的对象，数量为1，由当前玩家控制。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数：若对象仍与效果关联且表侧表示，则将其暂时除外，并注册一个在结束阶段将其返回场上的效果。
function c47295267.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且为表侧表示，并执行暂时除外（REASON_EFFECT+REASON_TEMPORARY）；若除外成功则继续。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 从游戏中除外的怪兽回到场上时，那只怪兽的攻击力变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c47295267.retop)
		-- 将结束阶段返回怪兽的诱发效果注册到当前玩家（tp）的场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段处理：将被暂时除外的怪兽返回场上；若成功，则为其附加攻击力变成原本攻击力2倍的效果，并设置在自己回合准备阶段将其破坏的效果。
function c47295267.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 尝试将被暂时除外的怪兽返回场上，若返回成功则进入后续处理。
	if Duel.ReturnToField(e:GetLabelObject()) then
		-- 从游戏中除外的怪兽回到场上时，那只怪兽的攻击力变成2倍。
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 下次的自己回合的准备阶段时，成为这张卡的对象的1只机械族的融合怪兽破坏。
		local e2=Effect.CreateEffect(e:GetOwner())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetCondition(c47295267.descon)
		e2:SetOperation(c47295267.desop)
		-- 判断当前回合玩家是否为自己，以决定破坏效果重置所需的阶段次数，使其能在正确地在自己回合准备阶段触发。
		if Duel.GetTurnPlayer()==tp then
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		tc:RegisterEffect(e2)
	end
end
-- 破坏效果的条件函数：要求当前回合是自己的回合，且对象怪兽仍为机械族。
function c47295267.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足破坏条件：当前回合玩家是自己且对象怪兽仍为机械族。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsRace(RACE_MACHINE)
end
-- 破坏效果的操作函数：破坏满足条件的对象怪兽。
function c47295267.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将对象怪兽破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
