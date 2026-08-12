--ピアニッシモ
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽的原本攻击力变成100，不会被战斗·效果破坏。
function c70899775.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽的原本攻击力变成100，不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为伤害步骤中伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c70899775.target)
	e1:SetOperation(c70899775.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择自己场上表侧表示且未适用过此效果的怪兽
function c70899775.filter(c)
	return c:IsFaceup() and c:GetFlagEffect(70899775)==0
end
-- 效果发动时的目标选择与合法性检测
function c70899775.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c70899775.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c70899775.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c70899775.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：使目标怪兽原本攻击力变成100，并赋予战斗和效果破坏抗性
function c70899775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:GetFlagEffect(70899775)==0 then
		tc:RegisterFlagEffect(70899775,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 这个回合，那只表侧表示怪兽的原本攻击力变成100
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不会被战斗·效果破坏
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e3)
	end
end
