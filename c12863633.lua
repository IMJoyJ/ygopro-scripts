--五稜星の呪縛
-- 效果：
-- 选择对方场上存在的1只怪兽发动。对方不能把选择的怪兽解放，也不能作为同调素材。
function c12863633.initial_effect(c)
	-- 创建一张永续效果，用于发动此卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c12863633.target)
	e1:SetOperation(c12863633.operation)
	c:RegisterEffect(e1)
end
-- 目标选择阶段的处理函数
function c12863633.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否能选择对方场上的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择对方场上的一只怪兽作为对象
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时的处理函数
function c12863633.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果所选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 对方不能把选择的怪兽解放
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_RELEASE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,0,1)
		e1:SetTarget(c12863633.rellimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方不能把选择的怪兽作为同调素材
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c12863633.synlimit)
		e3:SetOwnerPlayer(tp)
		tc:RegisterEffect(e3)
	end
end
-- 判断是否为被选择的怪兽
function c12863633.rellimit(e,c,tp)
	return c==e:GetHandler()
end
-- 判断是否为对方的怪兽
function c12863633.synlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetOwnerPlayer())
end
