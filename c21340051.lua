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
-- 召唤成功时必发效果的发动判定与操作信息设置：chk==0时直接返回true允许发动，并登记将破坏这张卡。
function c21340051.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息，登记破坏效果的对象为这张卡自身，数量为1，使其他卡能正确连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时的执行操作：若这张卡仍与当前效果关联（未因离场等重置），则将其破坏。
function c21340051.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏这张卡。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 攻击力增减效果的发动条件：检测对方场上是否存在至少1只怪兽。
function c21340051.con(e)
	-- 返回对方场上怪兽区的怪兽数量是否大于0。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
