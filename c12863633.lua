--五稜星の呪縛
-- 效果：
-- 选择对方场上存在的1只怪兽发动。对方不能把选择的怪兽解放，也不能作为同调素材。
function c12863633.initial_effect(c)
	-- 选择对方场上存在的1只怪兽发动。对方不能把选择的怪兽解放，也不能作为同调素材。
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
-- 发动时的对象选择处理：检查对方场上是否存在可选择的怪兽，然后提示玩家选择1只对方场上的怪兽作为效果对象。
function c12863633.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动合法性检查：确认对方场上存在至少1只可以成为效果对象的怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择效果的对象”的提示，引导玩家进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上的1只怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽，若对象仍与效果相关，则对其施加‘不能解放’和‘不能作为同调素材’两个效果。
function c12863633.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽（即连锁处理时保存的取对象目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 对方不能把选择的怪兽解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_RELEASE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,0,1)
		e1:SetTarget(c12863633.rellimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 也不能作为同调素材。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c12863633.synlimit)
		e3:SetOwnerPlayer(tp)
		tc:RegisterEffect(e3)
	end
end
-- “不能解放”的限制条件：仅当被解放/处理的卡是这张效果对象怪兽时适用。
function c12863633.rellimit(e,c,tp)
	return c==e:GetHandler()
end
-- “不能作为同调素材”的判定：若尝试作为同调素材的怪兽不属于效果发动者控制（即对方怪兽），则返回true表示不能作为同调素材。
function c12863633.synlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetOwnerPlayer())
end
