--デスカウンター
-- 效果：
-- 进行直接攻击并对玩家造成战斗伤害的怪兽被破坏。
function c39131963.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个诱发必发效果，用于处理战斗伤害时的破坏效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39131963,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c39131963.condition)
	e2:SetTarget(c39131963.target)
	e2:SetOperation(c39131963.operation)
	c:RegisterEffect(e2)
end
-- 效果条件函数，判断是否为直接攻击
function c39131963.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击目标是否为空，即是否为直接攻击
	return Duel.GetAttackTarget()==nil
end
-- 效果目标函数，设置破坏对象及操作信息
function c39131963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁中涉及的卡设为当前效果的目标
	Duel.SetTargetCard(eg)
	-- 设置操作信息为破坏类别，指定目标卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果处理函数，执行破坏操作
function c39131963.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
