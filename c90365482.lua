--河伯
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的场合，以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽变成当作灵魂怪兽使用，结束阶段回到持有者手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c90365482.initial_effect(c)
	-- 为这张卡注册灵魂怪兽共通的回手效果：召唤成功或反转的回合的结束阶段，这张卡回到持有者手卡
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件恒为假（aux.FALSE），使这张卡不能被特殊召唤
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
-- 效果的对象选择函数：确认双方场上存在可成为对象的表侧表示怪兽，并以其中1只为对象
function c90365482.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查双方怪兽区域是否存在1只以上可成为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家提示「请选择表侧表示的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家选择双方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使对象怪兽当作灵魂怪兽使用，并为其注册结束阶段回到持有者手卡的持续效果
function c90365482.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象怪兽
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
		-- 结束阶段回到持有者手卡
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c90365482.retcon)
		e2:SetOperation(c90365482.retop)
		-- 把结束阶段回手的持续效果注册到全局环境，使其在结束阶段触发
		Duel.RegisterEffect(e2,tp)
	end
end
-- 触发条件：确认目标怪兽身上的标志与效果记录的标记一致（不一致则重置此效果并不触发）
function c90365482.retcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(90365482)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 效果处理：将记录的对象怪兽送去持有者手卡
function c90365482.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将对象怪兽回到持有者手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
