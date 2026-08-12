--ドドドドライバー
-- 效果：
-- 这张卡被名字带有「怒怒怒」的怪兽的效果特殊召唤的回合，可以选择自己场上1只名字带有「怒怒怒」的怪兽，从以下效果选择1个发动。这个效果1回合可以使用最多2次。
-- ●选择的怪兽的等级上升1星。
-- ●选择的怪兽的等级下降1星。
function c85310252.initial_effect(c)
	-- 这张卡被名字带有「怒怒怒」的怪兽的效果特殊召唤的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c85310252.spcon)
	e1:SetOperation(c85310252.spop)
	c:RegisterEffect(e1)
	-- 可以选择自己场上1只名字带有「怒怒怒」的怪兽，从以下效果选择1个发动。这个效果1回合可以使用最多2次。●选择的怪兽的等级上升1星。●选择的怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85310252,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(2)
	e2:SetCondition(c85310252.condition)
	e2:SetTarget(c85310252.target)
	e2:SetOperation(c85310252.operation)
	c:RegisterEffect(e2)
end
-- 判定特殊召唤此卡的效果来源是否为名字带有「怒怒怒」的怪兽
function c85310252.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x82)
end
-- 给此卡注册一个持续到回合结束的Flag，用于标记其在本回合是由「怒怒怒」怪兽的效果特殊召唤的
function c85310252.spop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(85310252,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判定此卡是否带有由「怒怒怒」怪兽效果特殊召唤的Flag标记
function c85310252.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(85310252)>0
end
-- 过滤自己场上表侧表示、等级在1以上且名字带有「怒怒怒」的怪兽
function c85310252.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x82) and c:IsLevelAbove(1)
end
-- 效果发动时的对象选择与效果分支选择处理
function c85310252.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c85310252.filter(chkc) end
	-- 判定自己场上是否存在可以作为效果对象的「怒怒怒」怪兽
	if chk==0 then return Duel.IsExistingTarget(c85310252.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「怒怒怒」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c85310252.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local op=0
	-- 如果选择的怪兽等级为1，则只能选择“等级上升1星”的效果
	if tc:IsLevel(1) then op=Duel.SelectOption(tp,aux.Stringid(85310252,1))  --"等级上升1星"
	-- 如果选择的怪兽等级大于1，则让玩家在“等级上升1星”和“等级下降1星”中选择一个
	else op=Duel.SelectOption(tp,aux.Stringid(85310252,1),aux.Stringid(85310252,2)) end  --"等级上升1星/等级下降1星"
	e:SetLabel(op)
end
-- 效果处理：使选择的对象怪兽等级上升或下降1星
function c85310252.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ●选择的怪兽的等级上升1星。●选择的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else e1:SetValue(-1) end
		tc:RegisterEffect(e1)
	end
end
