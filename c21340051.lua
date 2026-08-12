--ボアソルジャー
-- 效果：
-- 被召唤的场合，这张卡破坏。对方控制着即使只有1只怪兽的场合，攻击力下降1000。
function c21340051.initial_effect(c)
	-- 被召唤的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c21340051.destg)
	e1:SetOperation(c21340051.desop)
	c:RegisterEffect(e1)
	-- 对方控制着即使只有1只怪兽的场合，攻击力下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c21340051.con)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
end
-- 设置效果处理时的连锁操作信息，指定将要破坏的卡片为自身
function c21340051.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁操作为破坏效果，并将自身设为破坏目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行破坏效果，若自身存在于场上则进行破坏
function c21340051.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身从游戏中破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断对方场上是否存在怪兽
function c21340051.con(e)
	-- 判断对方场上怪兽数量是否大于0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
