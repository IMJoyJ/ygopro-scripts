--帝王の凍志
-- 效果：
-- ①：自己的额外卡组没有卡存在的场合，以自己场上1只上级召唤的表侧表示怪兽为对象才能发动。那只怪兽效果无效，不受这张卡以外的效果影响。
function c26822796.initial_effect(c)
	-- ①：自己的额外卡组没有卡存在的场合，以自己场上1只上级召唤的表侧表示怪兽为对象才能发动。那只怪兽效果无效，不受这张卡以外的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c26822796.condition)
	e1:SetTarget(c26822796.target)
	e1:SetOperation(c26822796.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：仅在发动者自己的额外卡组没有卡存在时允许发动。
function c26822796.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp视角看自己的额外卡组（LOCATION_EXTRA）卡数为0，满足发动前提。
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
-- 定义对象筛选函数：目标必须为表侧表示，且是通过上级召唤方式出场的怪兽。
function c26822796.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 定义发动时的取对象处理：确认对象合法、检查场上是否存在可选中对象，然后提示并选择自己场上1只上级召唤的表侧表示怪兽。
function c26822796.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c26822796.filter(chkc) end
	-- 在效果发动合法性检查阶段，确认自己场上存在至少1只满足筛选条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c26822796.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只满足条件的表侧表示上级召唤怪兽作为效果对象。
	Duel.SelectTarget(tp,c26822796.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理：使对象怪兽效果无效，并让它不受这张卡以外的效果影响；包含无效相关连锁、赋予无效和免疫效果的处理。
function c26822796.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取取对象阶段选择的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该对象怪兽有关的连锁（已发动的效果）无效化，并设定在变里侧等时机重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 不受这张卡以外的效果影响。
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
-- 定义免疫过滤器：若试图对对象怪兽适用的效果不属于“帝王冻志”这张卡，则对象怪兽不受该效果影响。
function c26822796.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
