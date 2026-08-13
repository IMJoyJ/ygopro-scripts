--N・ブラック・パンサー
-- 效果：
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。直到结束阶段，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c43237273.initial_effect(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43237273,0))  --"效果复制"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c43237273.target)
	e1:SetOperation(c43237273.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：选择对方场上表侧表示且不是衍生物的怪兽作为对象。
function c43237273.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 发动前的取对象处理：校验是否存在合法对象，并让玩家从对方场上选择1只表侧表示且非衍生物的怪兽作为效果对象。
function c43237273.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c43237273.filter(chkc) end
	-- 在发动合法性检查（chk==0）时，确认对方场上是否存在至少1只满足条件的表侧表示怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c43237273.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从对方场上选择1只满足条件的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c43237273.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：确认本卡与对象仍关联且均表侧在场后，取得对象的原本卡号，将本卡卡名变为该卡号并复制对象的效果，同时注册结束阶段时解除这些复制效果的处理。
function c43237273.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象（即之前选择的对方场上表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 得到和那只怪兽的原本的卡名·效果相同的卡名·效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		-- 直到结束阶段
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(43237273,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c43237273.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段到时：按保存的复制ID重置复制的效果，并重置因无效化产生的残留效果；随后重置卡名变更效果，使本卡恢复原状；再展示本卡并向对方提示复制结束。
function c43237273.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 手动为本卡显示被选择/恢复的动画，并标记为效果处理涉及的对象。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家发送“对方选择了：”的提示，内容为当前效果描述，告知对方本效果的复制处理结束。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
