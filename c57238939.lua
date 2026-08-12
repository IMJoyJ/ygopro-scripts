--A・ジェネクス・リモート
-- 效果：
-- ①：1回合1次，以场上1只调整为对象才能发动。那只怪兽的卡名直到结束阶段当作「次世代控制员」使用。
function c57238939.initial_effect(c)
	-- ①：1回合1次，以场上1只调整为对象才能发动。那只怪兽的卡名直到结束阶段当作「次世代控制员」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57238939,0))  --"卡名变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c57238939.costg)
	e1:SetOperation(c57238939.cosop)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的调整怪兽
function c57238939.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 效果发动的目标选择与合法性检测（选择场上1只表侧表示的调整怪兽作为对象）
function c57238939.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c57238939.filter(chkc) end
	-- 检查场上是否存在可以作为效果对象的表侧表示调整怪兽
	if chk==0 then return Duel.IsExistingTarget(c57238939.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的调整怪兽作为效果对象
	Duel.SelectTarget(tp,c57238939.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，使作为对象的怪兽卡名直到结束阶段当作「次世代控制员」使用
function c57238939.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的卡名直到结束阶段当作「次世代控制员」使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(68505803)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
