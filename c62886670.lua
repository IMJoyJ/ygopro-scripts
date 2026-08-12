--海晶乙女シースター
-- 效果：
-- 这个卡名的效果1回合可以使用最多2次。
-- ①：把这张卡从手卡送去墓地，以自己场上1只「海晶少女」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
function c62886670.initial_effect(c)
	-- 这个卡名的效果1回合可以使用最多2次。①：把这张卡从手卡送去墓地，以自己场上1只「海晶少女」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62886670,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(2,62886670)
	e1:SetCost(c62886670.adcost)
	e1:SetTarget(c62886670.adtg)
	e1:SetOperation(c62886670.adop)
	c:RegisterEffect(e1)
end
-- 效果①的代价（Cost）处理函数，检查并执行将自身从手卡送去墓地的操作
function c62886670.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤自己场上表侧表示的「海晶少女」怪兽的条件函数
function c62886670.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b)
end
-- 效果①的对象（Target）处理函数，用于确认和选择自己场上1只表侧表示的「海晶少女」怪兽
function c62886670.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c62886670.filter(chkc) end
	-- 在发动阶段（chk==0）检查自己场上是否存在可以作为对象的「海晶少女」怪兽
	if chk==0 then return Duel.IsExistingTarget(c62886670.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「海晶少女」怪兽作为效果对象
	Duel.SelectTarget(tp,c62886670.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理（Operation）函数，使作为对象的怪兽攻击力上升800
function c62886670.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
