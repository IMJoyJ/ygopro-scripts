--海皇の重装兵
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的海龙族怪兽召唤。
-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合，以对方场上1张表侧表示的卡为对象发动。那张对方的表侧表示的卡破坏。
function c37104630.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的海龙族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37104630,1))  --"使用「海皇的重装兵」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(c37104630.extg)
	c:RegisterEffect(e1)
	-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合，以对方场上1张表侧表示的卡为对象发动。那张对方的表侧表示的卡破坏。
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
-- 可追加召唤的怪兽需满足4星以下且海龙族。
function c37104630.extg(e,c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SEASERPENT)
end
-- 发动条件：此卡为让水属性怪兽效果发动而被作为代价送去墓地，且该效果是已发动的水属性怪兽效果。
function c37104630.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 选择对象用的过滤函数：对象必须是表侧表示的卡。
function c37104630.desfilter(c)
	return c:IsFaceup()
end
-- 效果的目标筛选与登记：对象必须是对方场上表侧表示的卡；发动时让玩家选择1张并写入破坏操作信息。
function c37104630.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c37104630.desfilter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张表侧表示的卡作为效果对象，同时将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c37104630.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果分类为破坏，对象为已选择的卡，数量为1，供后续响应判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果结算：取得对象卡，若仍与效果关联且表侧表示，则将其破坏。
function c37104630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
