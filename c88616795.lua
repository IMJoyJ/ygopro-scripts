--トーラの魔導書
-- 效果：
-- ①：可以以场上1只魔法师族怪兽为对象，从以下效果选择1个发动。
-- ●这个回合，那只表侧表示怪兽不受这张卡以外的魔法卡的效果影响。
-- ●这个回合，那只表侧表示怪兽不受陷阱卡的效果影响。
function c88616795.initial_effect(c)
	-- ①：可以以场上1只魔法师族怪兽为对象，从以下效果选择1个发动。●这个回合，那只表侧表示怪兽不受这张卡以外的魔法卡的效果影响。●这个回合，那只表侧表示怪兽不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c88616795.target)
	e1:SetOperation(c88616795.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的魔法师族怪兽
function c88616795.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果①的发动准备，确认合法对象并由玩家选择对象和要适用的效果分支
function c88616795.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88616795.filter(chkc) end
	-- 检查场上是否存在至少1只可以作为效果对象的表侧表示魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c88616795.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的魔法师族怪兽作为效果的对象
	Duel.SelectTarget(tp,c88616795.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 让玩家从两个分支效果中选择一个发动，并将选择结果记录在效果的Label中
	local opt=Duel.SelectOption(tp,aux.Stringid(88616795,0),aux.Stringid(88616795,1))  --"不受这张卡以外的魔法卡的效果影响/不受陷阱卡的效果影响"
	e:SetLabel(opt)
end
-- 效果①的发动处理，使作为对象的怪兽在回合结束前获得所选的免疫效果
function c88616795.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- ●这个回合，那只表侧表示怪兽不受这张卡以外的魔法卡的效果影响。●这个回合，那只表侧表示怪兽不受陷阱卡的效果影响。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		if e:GetLabel()==0 then
			e2:SetValue(c88616795.efilter1)
		else
			e2:SetValue(c88616795.efilter2)
		end
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 过滤不受这张卡以外的魔法卡效果影响的条件
function c88616795.efilter1(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwner()~=e:GetOwner()
end
-- 过滤不受陷阱卡效果影响的条件
function c88616795.efilter2(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
