--暗黒の眠りを誘うルシファー
-- 效果：
-- ①：这张卡召唤·反转召唤成功的场合，以对方场上1只怪兽为对象发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，作为对象的怪兽不能攻击。
function c52675689.initial_effect(c)
	-- 诱发必发效果，对应通常召唤成功时的发动
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
-- 选择对方场上的1只怪兽作为对象
function c52675689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只怪兽作为对象
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将对象怪兽设置为不能攻击的效果
function c52675689.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 只要这张卡在怪兽区域存在，作为对象的怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c52675689.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断对象怪兽是否仍存在于场上
function c52675689.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
