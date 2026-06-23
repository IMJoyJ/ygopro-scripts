--女邪神ヌヴィア
-- 效果：
-- 召唤的场合，这张卡破坏。对方有怪兽控制的场合，对方场上每有1张可控制的怪兽这张卡的攻击力下降200。
function c12953226.initial_effect(c)
	-- 召唤的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c12953226.destg)
	e1:SetOperation(c12953226.desop)
	c:RegisterEffect(e1)
	-- 对方有怪兽控制的场合，对方场上每有1张可控制的怪兽这张卡的攻击力下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c12953226.val)
	c:RegisterEffect(e2)
end
-- 设置连锁处理时的目标为自身，用于破坏效果的发动检测
function c12953226.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁操作信息为破坏效果，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的处理函数，用于执行破坏操作
function c12953226.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身破坏，原因来自效果
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 计算攻击力下降值的函数
function c12953226.val(e,c)
	local tp=c:GetControler()
	-- 获取对方场上的怪兽数量并乘以-200作为攻击力下降值
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*-200
end
