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
-- 过滤满足条件的怪兽：表侧表示、机械族、融合怪兽且能除外
function c47295267.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
end
-- 设置效果目标为满足条件的怪兽
function c47295267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47295267.filter(chkc) end
	-- 判断是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c47295267.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽并设置为效果对象
	local g=Duel.SelectTarget(tp,c47295267.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，记录将要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果发动时的操作：将目标怪兽暂时除外
function c47295267.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且满足除外条件
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 创建一个在结束阶段触发的效果，用于处理怪兽返回场上的后续操作
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c47295267.retop)
		-- 注册该持续效果到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 处理怪兽返回场上时的后续效果：攻击力变为2倍并设置下次准备阶段破坏
function c47295267.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否成功将怪兽返回场上
	if Duel.ReturnToField(e:GetLabelObject()) then
		-- 设置目标怪兽的攻击力为原本的2倍
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个在下次自己回合准备阶段触发的效果，用于破坏该怪兽
		local e2=Effect.CreateEffect(e:GetOwner())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetCondition(c47295267.descon)
		e2:SetOperation(c47295267.desop)
		-- 判断是否为自己的回合
		if Duel.GetTurnPlayer()==tp then
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		tc:RegisterEffect(e2)
	end
end
-- 条件函数：判断是否为自己的回合且目标怪兽为机械族
function c47295267.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsRace(RACE_MACHINE)
end
-- 破坏效果处理函数：将目标怪兽破坏
function c47295267.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
