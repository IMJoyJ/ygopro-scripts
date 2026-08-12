--D-HERO ドレッドサーヴァント
-- 效果：
-- 这张卡召唤成功时，「幽狱之时计塔」放置1个时计指示物。这张卡被战斗破坏送去墓地时，可以把自己场上1张魔法·陷阱卡破坏。
function c36625827.initial_effect(c)
	-- 注册卡名记载：这张卡上记载着「幽狱之时计塔」的卡名（75041269）
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
c36625827.mentioned_counter={
	[0x1b]=true,
}
-- 过滤函数：检索表侧表示的「幽狱之时计塔」，且还能放置时计指示物
function c36625827.ctfilter(c)
	return c:IsFaceup() and c:IsCode(75041269) and c:IsCanAddCounter(0x1b,1)
end
-- 效果处理：给场上所有满足条件的「幽狱之时计塔」各放置1个时计指示物
function c36625827.addc(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方场地区满足条件的「幽狱之时计塔」
	local g=Duel.GetMatchingGroup(c36625827.ctfilter,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1b,1)
		tc=g:GetNext()
	end
end
-- 发动条件：这张卡在墓地存在且是被战斗破坏的
function c36625827.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：目标是魔法·陷阱卡
function c36625827.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 对象选择：确认自己场上存在可作为对象的魔法·陷阱卡，选择其中1张作为破坏对象并设置破坏操作信息
function c36625827.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c36625827.filter(chkc) end
	-- 检查自己场上是否存在可以成为对象的魔法·陷阱卡（效果能否发动的判定）
	if chk==0 then return Duel.IsExistingTarget(c36625827.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c36625827.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：本次连锁将破坏作为对象的卡（供王家长眠之谷等发动检测使用）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得对象卡，若其仍与本效果相关联则将其破坏
function c36625827.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
