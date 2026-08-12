--ギャラクシー・ストーム
-- 效果：
-- 选择场上存在的1只没有超量素材的超量怪兽破坏。
function c80887714.initial_effect(c)
	-- 选择场上存在的1只没有超量素材的超量怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c80887714.target)
	e1:SetOperation(c80887714.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示、且没有超量素材的超量怪兽
function c80887714.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
-- 效果发动时的目标选择与操作信息设置
function c80887714.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c80887714.filter(chkc) end
	-- 在发动阶段，检查场上是否存在至少1只满足过滤条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c80887714.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只符合过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80887714.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明此连锁的处理是破坏选中的这1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数，用于破坏选中的对象怪兽
function c80887714.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时所选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
