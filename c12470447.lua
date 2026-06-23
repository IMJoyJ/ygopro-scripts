--邪悪な儀式
-- 效果：
-- 场上全部怪兽的表示形式交换。发动回合，怪兽的表示形式不能变更。这张卡只能在准备阶段发动。
function c12470447.initial_effect(c)
	-- 将此卡作为永续效果注册到场上
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(0,EFFECT_FLAG2_COF)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCondition(c12470447.condition)
	e1:SetTarget(c12470447.target)
	e1:SetOperation(c12470447.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断函数
function c12470447.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY
		-- 判断此卡在魔法陷阱区且当前无连锁处理
		and e:GetHandler():IsLocation(LOCATION_SZONE) and Duel.GetCurrentChain()==0
end
-- 效果发动时的处理函数
function c12470447.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	-- 获取场上所有怪兽的卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果发动时的处理函数
function c12470447.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有怪兽的卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if g:GetCount()>0 then
		-- 将场上所有怪兽的表示形式交换
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
	-- 将不能改变表示形式的效果注册到场上
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能改变表示形式的效果
	Duel.RegisterEffect(e1,tp)
end
