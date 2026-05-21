--河伯
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的场合，以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽变成当作灵魂怪兽使用，结束阶段回到持有者手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c90365482.initial_effect(c)
	-- 为自身注册召唤·反转的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不可行（即不能特殊召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转的场合，以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽变成当作灵魂怪兽使用，结束阶段回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90365482,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c90365482.postg)
	e2:SetOperation(c90365482.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 效果①的发动准备与对象选择函数
function c90365482.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动时，检查场上是否存在至少1只表侧表示的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理函数，为对象怪兽添加灵魂属性并注册结束阶段回手卡的效果
function c90365482.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(90365482,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 那只表侧表示怪兽变成当作灵魂怪兽使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_SPIRIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 结束阶段回到持有者手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c90365482.retcon)
		e2:SetOperation(c90365482.retop)
		-- 在全局环境注册一个在结束阶段触发的延迟效果，用于将对象怪兽送回手卡
		Duel.RegisterEffect(e2,tp)
	end
end
-- 回手效果的触发条件判定函数，若对象怪兽已离场或标记失效则重置该效果
function c90365482.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetLabelObject():GetFlagEffectLabel(90365482)==e:GetLabel()) then
		e:Reset()
		return false
	else return true end
end
-- 回手效果的执行函数，在结束阶段将对象怪兽送回手卡
function c90365482.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽因效果送回持有者的手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
