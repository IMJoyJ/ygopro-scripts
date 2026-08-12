--宝玉獣 トパーズ・タイガー
-- 效果：
-- ①：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升400。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c95600067.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c95600067.repcon)
	e1:SetOperation(c95600067.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c95600067.condition)
	e2:SetValue(400)
	c:RegisterEffect(e2)
end
-- 判断自身是否在怪兽区域表侧表示被破坏，作为代替送去墓地效果的触发条件
function c95600067.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 执行代替送去墓地的操作，将自身作为永续魔法卡在魔法与陷阱区域表侧表示放置
function c95600067.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 判断是否在伤害步骤内，且自身向对方怪兽发动攻击
function c95600067.condition(e)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL)
		-- 判断攻击怪兽是否为自身，且攻击对象不为空
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
