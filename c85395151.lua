--洗脳解放
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：手卡·场上的怪兽被解放的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽的原本持有者对应的以下效果适用。
-- ●自己：得到作为对象的怪兽的控制权。这个效果得到控制权的怪兽在结束阶段回到手卡。
-- ●对方：作为对象的怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 定义卡片发动时的效果初始化函数，设置效果分类、类型、触发时点、属性、发动次数限制、条件、对象选择和效果处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：手卡·场上的怪兽被解放的场合，以对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选原本在手卡或场上被解放的怪兽卡。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
-- 发动条件：检查被解放的卡片中是否存在原本在手卡或场上的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
-- 过滤函数：筛选对方场上表侧表示的、且根据原本持有者满足相应适用条件的怪兽（原本持有者是自己则需能改变控制权，原本持有者是对方则需是未被无效的效果怪兽）。
function s.crbfilter(c,tp)
	if not c:IsFaceup() then return false end
	local cp=c:GetOwner()
	if cp==tp then
		return c:IsControlerCanBeChanged()
	elseif cp~=tp then
		-- 判定该怪兽是否为表侧表示、未被无效的效果怪兽。
		return aux.NegateEffectMonsterFilter(c)
	end
	return false
end
-- 效果发动时的目标选择与处理，确认是否有合法对象，并根据对象的原本持有者设置相应的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.crbfilter(chkc,tp) end
	-- 在发动阶段，检测对方场上是否存在符合条件的表侧表示怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.crbfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向发动效果的玩家发送提示信息，要求选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让发动效果的玩家选择对方场上1只符合条件的表侧表示怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.crbfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	local cp=g:GetFirst():GetOwner()
	if cp==tp then
		-- 设置操作信息：表明该连锁的处理包含改变1只怪兽控制权的操作。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	elseif cp~=tp then
		-- 设置操作信息：表明该连锁的处理包含无效1只怪兽效果的操作。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- 效果处理函数：根据作为对象的怪兽的原本持有者，适用对应的控制权转移及回手牌效果，或者无效其效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的唯一对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local cp=tc:GetOwner()
		if cp==tp and tc:IsControler(1-tp) then
			-- 将作为对象的怪兽的控制权转移给发动效果的玩家。
			Duel.GetControl(tc,tp)
			local fid=e:GetHandler():GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- ●自己：这个效果得到控制权的怪兽在结束阶段回到手卡。●对方：作为对象的怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.thcon)
			e1:SetOperation(s.thop)
			-- 注册全局延迟效果，用于在结束阶段将该怪兽送回持有者手卡。
			Duel.RegisterEffect(e1,tp)
		elseif cp~=tp and tc:IsCanBeDisabledByEffect(e) then
			-- 使与该怪兽相关的连锁中已发动的效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- ●对方：作为对象的怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- ●对方：作为对象的怪兽的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 结束阶段回手牌效果的触发条件判定，检查该怪兽是否仍带有对应的标记，若已离场或标记失效则重置该效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段回手牌效果的具体处理，将目标怪兽送回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在不入连锁的效果处理时，向双方玩家展示“洗脑解放”的卡片发动动画。
	Duel.Hint(HINT_CARD,0,id)
	-- 通过效果将目标怪兽送回其原本持有者的手卡。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
