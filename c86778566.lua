--攻撃の無敵化
-- 效果：
-- 战斗阶段时才能从以下效果选择1个发动。
-- ●选择场上1只怪兽才能发动。选择的怪兽在这次战斗阶段中不会被战斗以及卡的效果破坏。
-- ●这次战斗阶段中，对自己的战斗伤害变成0。
function c86778566.initial_effect(c)
	-- 战斗阶段时才能从以下效果选择1个发动。●选择场上1只怪兽才能发动。选择的怪兽在这次战斗阶段中不会被战斗以及卡的效果破坏。●这次战斗阶段中，对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c86778566.condition)
	e1:SetTarget(c86778566.target)
	e1:SetOperation(c86778566.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制只能在战斗阶段发动
function c86778566.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始步骤到结束步骤）
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义效果发动时的目标选择与分支选择处理
function c86778566.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	local opt=0
	-- 检查场上是否存在可以作为效果对象的怪兽
	if Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		-- 若场上有怪兽，让玩家从两个效果中选择一个发动
		opt=Duel.SelectOption(tp,aux.Stringid(86778566,0),aux.Stringid(86778566,1))  --"选择怪兽不会被战斗以及卡的效果破坏/这次战斗阶段中，对自己的战斗伤害变成0"
	-- 若场上没有怪兽，则玩家只能选择第二个效果（对自己的战斗伤害变成0）
	else opt=Duel.SelectOption(tp,aux.Stringid(86778566,1))+1 end  --"这次战斗阶段中，对自己的战斗伤害变成0"
	e:SetLabel(opt)
	if opt==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 设置提示信息，提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择场上1只怪兽作为效果的对象
		Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	else e:SetProperty(0) end
end
-- 定义效果处理函数，根据发动时选择的分支执行对应的效果
function c86778566.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取发动时选择的怪兽对象
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 选择的怪兽在这次战斗阶段中不会被战斗以及卡的效果破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
	else
		-- 这次战斗阶段中，对自己的战斗伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 在全局注册该效果，使玩家在这次战斗阶段中受到的战斗伤害变成0
		Duel.RegisterEffect(e1,tp)
	end
end
