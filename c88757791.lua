--法眼の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，把手卡1只灵摆怪兽给对方观看，以自己的灵摆区域1张「魔术师」卡为对象才能发动。那张「魔术师」卡的灵摆刻度直到回合结束时变成和给人观看的灵摆怪兽的灵摆刻度相同。
-- 【怪兽效果】
-- ①：只要这个回合灵摆召唤的这张卡在怪兽区域存在，自己场上的「魔术师」灵摆怪兽不会被对方的效果破坏。
function c88757791.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，把手卡1只灵摆怪兽给对方观看，以自己的灵摆区域1张「魔术师」卡为对象才能发动。那张「魔术师」卡的灵摆刻度直到回合结束时变成和给人观看的灵摆怪兽的灵摆刻度相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88757791,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c88757791.sctg)
	e2:SetOperation(c88757791.scop)
	c:RegisterEffect(e2)
	-- 只要这个回合灵摆召唤的这张卡在怪兽区域存在
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c88757791.sumsuc)
	c:RegisterEffect(e3)
	-- ①：只要这个回合灵摆召唤的这张卡在怪兽区域存在，自己场上的「魔术师」灵摆怪兽不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c88757791.indcon)
	e4:SetTarget(c88757791.indtg)
	-- 设置不会被对方的效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
end
-- 过滤手卡中未公开的灵摆怪兽，且自己灵摆区存在刻度与其不同的「魔术师」卡
function c88757791.cfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and not c:IsPublic()
		-- 检查自己灵摆区是否存在可以作为对象的「魔术师」卡
		and Duel.IsExistingTarget(c88757791.scfilter,tp,LOCATION_PZONE,0,1,nil,c)
end
-- 过滤自己灵摆区中刻度与展示怪兽不同的「魔术师」卡
function c88757791.scfilter(c,pc)
	return c:IsSetCard(0x98) and c:GetLeftScale()~=pc:GetLeftScale()
end
-- 灵摆效果的Target函数，处理展示手卡怪兽和选择灵摆区对象
function c88757791.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and c88757791.scfilter(chkc,e:GetLabelObject()) end
	-- 检查手卡中是否存在可展示的灵摆怪兽且灵摆区有对应的「魔术师」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c88757791.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张满足条件的灵摆怪兽
	local cg=Duel.SelectMatchingCard(tp,c88757791.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将选择的卡给对方确认
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
	e:SetLabelObject(cg:GetFirst())
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己灵摆区1张「魔术师」卡作为效果对象
	Duel.SelectTarget(tp,c88757791.scfilter,tp,LOCATION_PZONE,0,1,1,nil,cg:GetFirst())
end
-- 灵摆效果的Operation函数，改变作为对象的「魔术师」卡的灵摆刻度
function c88757791.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「魔术师」卡
	local tc=Duel.GetFirstTarget()
	local pc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 那张「魔术师」卡的灵摆刻度直到回合结束时变成和给人观看的灵摆怪兽的灵摆刻度相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(pc:GetLeftScale())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(pc:GetRightScale())
		tc:RegisterEffect(e2)
	end
end
-- 特殊召唤成功时，为自身注册一个持续到回合结束的Flag，用于标记“这个回合特殊召唤”
function c88757791.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(88757791,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 破坏抗性效果的启用条件：自身在这个回合灵摆召唤成功
function c88757791.indcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(88757791)~=0 and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤自己场上的「魔术师」灵摆怪兽作为破坏抗性的适用对象
function c88757791.indtg(e,c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
