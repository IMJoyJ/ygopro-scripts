--最後の進軍
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。直到这个回合的结束阶段时，选择的怪兽的效果无效化，不受这张卡以外的魔法·陷阱卡的效果影响。
function c28643791.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c28643791.target)
	e1:SetOperation(c28643791.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡必须是表侧表示且卡名带有「极神」（0x4b）的怪兽。
function c28643791.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 发动时的目标处理：检查是否存在合法对象，并选择1只自己场上表侧表示的名字带有「极神」的怪兽作为效果对象。
function c28643791.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28643791.filter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只满足条件的「极神」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c28643791.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示“请选择表侧表示的卡”的提示信息，用于选择对象时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示的「极神」怪兽中选择1只，并将其设置为效果的处理对象（取对象）。
	local g=Duel.SelectTarget(tp,c28643791.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理部分：获取对象，确认对象仍表侧且与效果关联后，赋予对象“效果无效化”和“不受这张卡以外的魔法·陷阱卡效果影响”的效果，持续到回合结束。
function c28643791.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的效果无效化（使其怪兽效果无效）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 选择的怪兽的效果无效化（使其已适用的效果也无效）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 不受这张卡以外的魔法·陷阱卡的效果影响。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c28643791.imfilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 免疫判定：效果来源是魔法·陷阱卡，且不是「最后的进军」自身时，该效果对对象怪兽无效。
function c28643791.imfilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetOwner()~=e:GetOwner()
end
