--最後の進軍
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。直到这个回合的结束阶段时，选择的怪兽的效果无效化，不受这张卡以外的魔法·陷阱卡的效果影响。
function c28643791.initial_effect(c)
	-- 创建卡的效果，设置为魔法卡发动效果，自由连锁，具有取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c28643791.target)
	e1:SetOperation(c28643791.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否表侧表示且卡名含有「极神」
function c28643791.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 选择效果对象：选择自己场上表侧表示存在的1只名字带有「极神」的怪兽
function c28643791.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28643791.filter(chkc) end
	-- 检查阶段：确认场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c28643791.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标：选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c28643791.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：对选中的怪兽施加效果
function c28643791.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到这个回合的结束阶段时，选择的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 直到这个回合的结束阶段时，选择的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 直到这个回合的结束阶段时，选择的怪兽不受这张卡以外的魔法·陷阱卡的效果影响
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c28643791.imfilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 免疫效果过滤函数：免疫除自身外的魔法·陷阱卡效果
function c28643791.imfilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetOwner()~=e:GetOwner()
end
