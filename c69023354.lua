--機甲忍者エアー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，选择自己场上1只名字带有「忍者」的怪兽才能发动。选择的怪兽的等级下降1星。
function c69023354.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，选择自己场上1只名字带有「忍者」的怪兽才能发动。选择的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69023354,0))  --"等级下降"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c69023354.target)
	e1:SetOperation(c69023354.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示、等级不为0且卡名带有「忍者」的怪兽
function c69023354.filter(c)
	return c:IsFaceup() and c:GetLevel()~=0 and c:IsSetCard(0x2b)
end
-- 效果发动时的对象选择处理，确认是否存在可选对象并选择1只符合条件的怪兽作为效果对象
function c69023354.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c69023354.filter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的「忍者」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c69023354.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「忍者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69023354.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理，使选择的对象怪兽等级下降1星
function c69023354.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
	end
end
