--デルタフライ
-- 效果：
-- ①：1回合1次，以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的等级上升1星。
function c57568840.initial_effect(c)
	-- ①：1回合1次，以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57568840,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c57568840.lvtg)
	e1:SetOperation(c57568840.lvop)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且具有等级的怪兽
function c57568840.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 效果发动的对象选择与合法性检测
function c57568840.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57568840.filter(chkc) end
	-- 在发动阶段，检测自己场上是否存在除这张卡以外的、表侧表示且有等级的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c57568840.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置提示信息为选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只除这张卡以外的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c57568840.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：使选择的对象怪兽等级上升1星
function c57568840.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只自己怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
