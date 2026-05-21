--DDDヘッドハント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「DDD」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到下个回合的结束阶段得到。这个效果得到控制权的怪兽的效果无效化，不能攻击宣言。这个效果得到控制权的怪兽是从额外卡组特殊召唤的怪兽的场合，那只怪兽也当作「DDD」怪兽使用。
function c91781484.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「DDD」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到下个回合的结束阶段得到。这个效果得到控制权的怪兽的效果无效化，不能攻击宣言。这个效果得到控制权的怪兽是从额外卡组特殊召唤的怪兽的场合，那只怪兽也当作「DDD」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,91781484+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c91781484.condition)
	e1:SetTarget(c91781484.target)
	e1:SetOperation(c91781484.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为表侧表示的「DDD」怪兽
function c91781484.cfilter(c)
	return c:IsSetCard(0x10af) and c:IsFaceup()
end
-- 发动条件：自己场上存在表侧表示的「DDD」怪兽
function c91781484.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「DDD」怪兽
	return Duel.IsExistingMatchingCard(c91781484.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查卡片是否为表侧表示且可以改变控制权的怪兽
function c91781484.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果的发动准备与目标选择：选择对方场上1只表侧表示怪兽为对象，并设置改变控制权的操作信息
function c91781484.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c91781484.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以成为对象且可以改变控制权的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c91781484.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91781484.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：改变所选怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获取对象怪兽并尝试在下个回合结束前获得其控制权，若成功则适用无效化、不能攻击以及可能的当作「DDD」怪兽使用的效果
function c91781484.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍受此效果影响，并尝试让玩家获得其控制权直到下个回合的结束阶段
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,2)~=0 then
		-- 不能攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 这个效果得到控制权的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		-- 这个效果得到控制权的怪兽的效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
		if tc:IsSummonLocation(LOCATION_EXTRA) then
			-- 这个效果得到控制权的怪兽是从额外卡组特殊召唤的怪兽的场合，那只怪兽也当作「DDD」怪兽使用。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_ADD_SETCODE)
			e4:SetValue(0x10af)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e4)
		end
	end
end
