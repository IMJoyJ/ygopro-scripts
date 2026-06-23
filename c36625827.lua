--D-HERO ドレッドサーヴァント
-- 效果：
-- 这张卡召唤成功时，「幽狱之时计塔」放置1个时计指示物。这张卡被战斗破坏送去墓地时，可以把自己场上1张魔法·陷阱卡破坏。
function c36625827.initial_effect(c)
	-- 注册卡片效果中涉及的其他卡片编号，用于识别「幽狱之时计塔」
	aux.AddCodeList(c,75041269)
	-- 这张卡召唤成功时，「幽狱之时计塔」放置1个时计指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36625827,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c36625827.addc)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地时，可以把自己场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36625827,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c36625827.descon)
	e2:SetTarget(c36625827.destg)
	e2:SetOperation(c36625827.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上正面表示的「幽狱之时计塔」且能放置时计指示物的卡片
function c36625827.ctfilter(c)
	return c:IsFaceup() and c:IsCode(75041269) and c:IsCanAddCounter(0x1b,1)
end
-- 将满足条件的「幽狱之时计塔」放置1个时计指示物
function c36625827.addc(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的「幽狱之时计塔」
	local g=Duel.GetMatchingGroup(c36625827.ctfilter,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1b,1)
		tc=g:GetNext()
	end
end
-- 判断效果是否触发：卡片是否在墓地且因战斗被破坏
function c36625827.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选魔法或陷阱类型的卡片
function c36625827.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置选择目标阶段：选择场上自己一方的1张魔法或陷阱卡作为破坏对象
function c36625827.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c36625827.filter(chkc) end
	-- 判断是否满足选择目标的条件：场上是否存在1张自己一方的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c36625827.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上自己一方的1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c36625827.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：记录本次效果将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作：将选定的魔法或陷阱卡破坏
function c36625827.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
