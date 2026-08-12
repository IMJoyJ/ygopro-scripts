--ヒーローハート
-- 效果：
-- 选择自己场上1只表侧表示存在的名字带有「元素英雄」的怪兽发动。这个回合选择的怪兽的攻击力变成一半，同1次战斗阶段中可以攻击2次。
function c67951831.initial_effect(c)
	-- 选择自己场上1只表侧表示存在的名字带有「元素英雄」的怪兽发动。这个回合选择的怪兽的攻击力变成一半，同1次战斗阶段中可以攻击2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c67951831.target)
	e1:SetOperation(c67951831.activate)
	c:RegisterEffect(e1)
end
-- 过滤出表侧表示的「元素英雄」怪兽
function c67951831.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果发动的靶向处理，用于检测和选择符合条件的怪兽作为效果对象
function c67951831.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67951831.filter(chkc) end
	-- 在发动阶段检查自己场上是否存在符合条件的「元素英雄」怪兽
	if chk==0 then return Duel.IsExistingTarget(c67951831.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「元素英雄」怪兽作为效果对象
	Duel.SelectTarget(tp,c67951831.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理，使目标怪兽攻击力减半并获得追加攻击的效果
function c67951831.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合选择的怪兽的攻击力变成一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 同1次战斗阶段中可以攻击2次。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
