--女邪神ヌヴィア
-- 效果：
-- 召唤的场合，这张卡破坏。对方有怪兽控制的场合，对方场上每有1张可控制的怪兽这张卡的攻击力下降200。
function c12953226.initial_effect(c)
	-- 对应效果原文：召唤的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c12953226.destg)
	e1:SetOperation(c12953226.desop)
	c:RegisterEffect(e1)
	-- 对应效果原文：对方有怪兽控制的场合，对方场上每有1张可控制的怪兽这张卡的攻击力下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c12953226.val)
	c:RegisterEffect(e2)
end
-- 作为召唤成功时的诱发必发效果的发动条件判定，发动时点无条件允许发动，并登记将这张卡自身破坏的操作信息。
function c12953226.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏，对象为这张卡自身，数量为1，用于其他卡（如星尘龙）确认这个效果将进行破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍然与当前效果关联（没有被其他效果转移或离场导致关系重置），则将这张卡自身破坏。
function c12953226.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因将这张卡破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 计算攻击力变化值的函数：取得这张卡的控制者，再统计对方场上怪兽区的怪兽数量。
function c12953226.val(e,c)
	local tp=c:GetControler()
	-- 返回对方场上怪兽区怪兽数量乘以-200，作为这张卡攻击力的下降数值。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*-200
end
