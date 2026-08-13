--機甲忍者フレイム
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，选择自己场上1只名字带有「忍者」的怪兽才能发动。选择的怪兽的等级上升1星。
function c33034646.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，选择自己场上1只名字带有「忍者」的怪兽才能发动。选择的怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33034646,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33034646.target)
	e1:SetOperation(c33034646.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤出自己场上表侧表示、等级1以上且名字带有「忍者」的怪兽，作为可选的对象。
function c33034646.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsSetCard(0x2b)
end
-- 效果发动时的目标选择处理：先验证是否存在符合条件的对象，存在则提示玩家从自己场上选择1只表侧表示的名字带有「忍者」的怪兽作为效果对象。
function c33034646.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33034646.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的表侧表示「忍者」怪兽，作为效果能否发动的判定条件。
	if chk==0 then return Duel.IsExistingTarget(c33034646.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向当前玩家发送选择提示，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家从自己场上选择1只符合条件的怪兽，并将其登记为本次连锁的效果对象。
	Duel.SelectTarget(tp,c33034646.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理阶段：取得效果对象后，若该怪兽仍表侧表示且与效果关联，则给其赋予等级上升1星的永续效果。
function c33034646.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
