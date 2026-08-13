--暗黒の眠りを誘うルシファー
-- 效果：
-- ①：这张卡召唤·反转召唤成功的场合，以对方场上1只怪兽为对象发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，作为对象的怪兽不能攻击。
function c52675689.initial_effect(c)
	-- ①：这张卡召唤·反转召唤成功的场合，以对方场上1只怪兽为对象发动。这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52675689,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c52675689.target)
	e1:SetOperation(c52675689.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果发动时的对象选择函数：检查指定对象是否为对方场上的怪兽；在发动判定成功后，提示玩家并选择1只对方场上的怪兽作为效果对象。
function c52675689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动合法性检查：若对方场上不存在任何可选择的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择对象的提示消息（“请选择效果的对象”），用于提示玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择1只怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：验证发动怪兽仍与效果关联且表侧表示、对象怪兽仍与效果关联且不对此效果免疫后，将对象怪兽设为这张卡的永续对象，并给对象怪兽赋予“不能攻击”的效果，该效果随卡片离场等标准时机重置。
function c52675689.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- ●只要这张卡在怪兽区域存在，作为对象的怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c52675689.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- “不能攻击”效果的适用条件：效果持有者（这张卡）仍以受该效果影响的怪兽为永续对象，即这张卡仍存在且仍以那只怪兽为对象时才适用。
function c52675689.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
