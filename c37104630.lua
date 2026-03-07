--海皇の重装兵
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的海龙族怪兽召唤。
-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合，以对方场上1张表侧表示的卡为对象发动。那张对方的表侧表示的卡破坏。
function c37104630.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的海龙族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37104630,1))  --"使用「海皇的重装兵」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(c37104630.extg)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合，以对方场上1张表侧表示的卡为对象发动。那张对方的表侧表示的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37104630,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c37104630.descon)
	e2:SetTarget(c37104630.destg)
	e2:SetOperation(c37104630.desop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：设置效果只能选择4星以下的海龙族怪兽作为额外召唤目标
function c37104630.extg(e,c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SEASERPENT)
end
-- 规则层面作用：判断是否满足效果发动条件，即该卡因支付代价送去墓地且是水属性怪兽效果发动
function c37104630.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 规则层面作用：过滤对方场上表侧表示的卡作为破坏目标
function c37104630.desfilter(c)
	return c:IsFaceup()
end
-- 规则层面作用：选择对方场上一张表侧表示的卡作为破坏对象，并设置操作信息
function c37104630.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c37104630.desfilter(chkc) end
	if chk==0 then return true end
	-- 规则层面作用：向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择对方场上一张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c37104630.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面作用：设置当前连锁的操作信息为破坏效果，目标为已选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面作用：执行破坏效果，将目标卡破坏
function c37104630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的破坏目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 规则层面作用：以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
