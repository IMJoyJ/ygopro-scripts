--波動再生
-- 效果：
-- 对方怪兽的直接攻击宣言时，从自己墓地选择持有那只攻击怪兽的等级以下的等级的1只同调怪兽发动。那个时候的攻击发生的对自己的战斗伤害变成一半数值。那次伤害步骤结束时，选择的同调怪兽从自己墓地特殊召唤。
function c60312997.initial_effect(c)
	-- 对方怪兽的直接攻击宣言时，从自己墓地选择持有那只攻击怪兽的等级以下的等级的1只同调怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c60312997.condition)
	e1:SetTarget(c60312997.target)
	e1:SetOperation(c60312997.operation)
	c:RegisterEffect(e1)
end
-- 判定是否满足对方怪兽直接攻击宣言时的发动条件
function c60312997.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为对方回合，且攻击对象为空（即直接攻击）
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil
		and eg:GetFirst():IsLocation(LOCATION_MZONE)
end
-- 过滤自己墓地中等级在攻击怪兽等级以下、且可以特殊召唤的同调怪兽
function c60312997.filter(c,lv)
	return c:IsLevelBelow(lv) and c:IsType(TYPE_SYNCHRO) and c:IsSpecialSummonableCard()
end
-- 效果发动时的对象选择与合法性检测
function c60312997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c60312997.filter(chkc,eg:GetFirst():GetLevel()) end
	-- 检查自己墓地是否存在符合条件的同调怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c60312997.filter,tp,LOCATION_GRAVE,0,1,nil,eg:GetFirst():GetLevel()) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只符合条件的同调怪兽作为效果对象
	Duel.SelectTarget(tp,c60312997.filter,tp,LOCATION_GRAVE,0,1,1,nil,eg:GetFirst():GetLevel())
end
-- 效果处理，注册伤害减半效果，并注册伤害步骤结束时特殊召唤该怪兽的效果
function c60312997.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 那个时候的攻击发生的对自己的战斗伤害变成一半数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	-- 注册使玩家受到的战斗伤害减半的效果
	Duel.RegisterEffect(e1,tp)
	-- 获取作为效果对象的同调怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那次伤害步骤结束时，选择的同调怪兽从自己墓地特殊召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c60312997.spop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册在伤害步骤结束时触发特殊召唤效果的延迟效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害步骤结束时，将作为对象的同调怪兽特殊召唤
function c60312997.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=e:GetLabelObject()
	if tc:IsLocation(LOCATION_GRAVE) then
		-- 将目标同调怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
