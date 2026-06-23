--帝王の凍志
-- 效果：
-- ①：自己的额外卡组没有卡存在的场合，以自己场上1只上级召唤的表侧表示怪兽为对象才能发动。那只怪兽效果无效，不受这张卡以外的效果影响。
function c26822796.initial_effect(c)
	-- 效果定义：魔法卡发动，自由时点，需要选择对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c26822796.condition)
	e1:SetTarget(c26822796.target)
	e1:SetOperation(c26822796.activate)
	c:RegisterEffect(e1)
end
-- 条件：自己的额外卡组没有卡存在
function c26822796.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断额外卡组是否为空
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
-- 过滤器：表侧表示且上级召唤的怪兽
function c26822796.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果目标选择：选择自己场上1只表侧表示的上级召唤怪兽
function c26822796.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c26822796.filter(chkc) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c26822796.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c26822796.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使目标怪兽效果无效并免疫其他效果
function c26822796.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ①：那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ①：不受这张卡以外的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- ①：不受这张卡以外的效果影响
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c26822796.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
-- 效果免疫函数：排除自身效果的影响
function c26822796.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
