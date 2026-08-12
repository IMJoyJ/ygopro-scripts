--運命のドラ
-- 效果：
-- 这张卡只能在对方回合发动。选择对方场上1只以表侧表示存在的怪兽。下一个自己的回合，若自己成功召唤出比被选择的怪兽低1颗星的怪兽，则召唤成功时对对方造成被选择的怪兽等级×500点伤害。
function c67464807.initial_effect(c)
	-- 这张卡只能在对方回合发动。选择对方场上1只以表侧表示存在的怪兽。下一个自己的回合，若自己成功召唤出比被选择的怪兽低1颗星的怪兽，则召唤成功时对对方造成被选择的怪兽等级×500点伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c67464807.condition)
	e1:SetTarget(c67464807.target)
	e1:SetOperation(c67464807.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：只能在对方回合发动
function c67464807.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：对方场上表侧表示且等级在2星以上的怪兽
function c67464807.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 效果发动时的目标选择与合法性检查
function c67464807.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c67464807.filter(chkc) end
	-- 在发动准备阶段，检查对方场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c67464807.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c67464807.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽的等级，并注册一个在下个自己回合召唤成功时触发伤害的全局效果
function c67464807.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		if lv>1 then
			-- 下一个自己的回合，若自己成功召唤出比被选择的怪兽低1颗星的怪兽，则召唤成功时对对方造成被选择的怪兽等级×500点伤害。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SUMMON_SUCCESS)
			e1:SetCountLimit(1)
			e1:SetCondition(c67464807.damcon)
			e1:SetOperation(c67464807.damop)
			e1:SetLabel(lv)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 将该延迟触发的伤害效果注册给玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 伤害效果触发条件判定
function c67464807.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合、是否是自己成功进行通常召唤，且召唤的怪兽等级比被选择的怪兽低1颗星
	return Duel.GetTurnPlayer()==tp and ep==tp and eg:GetFirst():IsLevel(e:GetLabel()-1)
end
-- 伤害效果执行：给予对方伤害
function c67464807.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方造成被选择的怪兽等级×500点的效果伤害
	Duel.Damage(1-tp,e:GetLabel()*500,REASON_EFFECT)
end
