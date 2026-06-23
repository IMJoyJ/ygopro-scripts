--N・ブラック・パンサー
-- 效果：
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。直到结束阶段，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c43237273.initial_effect(c)
	-- 效果复制
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
-- 选择对方场上的1只表侧表示怪兽作为对象
function c43237273.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 检索满足条件的卡片组
function c43237273.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c43237273.filter(chkc) end
	-- 判断是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(c43237273.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c43237273.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽的卡名和效果复制到自身
function c43237273.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 直到结束阶段，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果
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
		-- 在结束阶段时，将自身恢复为原本的卡名和效果
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
-- 重置效果并恢复为原本状态
function c43237273.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
