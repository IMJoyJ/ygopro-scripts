--呪言の鏡
-- 效果：
-- 对方从卡组把怪兽特殊召唤时才能发动。那些怪兽破坏，从自己卡组抽1张卡。
function c46656406.initial_effect(c)
	-- 对方从卡组把怪兽特殊召唤时才能发动。那些怪兽破坏，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c46656406.target)
	e1:SetOperation(c46656406.activate)
	c:RegisterEffect(e1)
end
-- 筛选出由对方特殊召唤且之前在卡组的怪兽
function c46656406.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果处理时检查是否满足条件并设置操作信息
function c46656406.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有符合条件的怪兽以及玩家能否抽卡
	if chk==0 then return eg:IsExists(c46656406.filter,1,nil,tp) and Duel.IsPlayerCanDraw(tp,1) end
	local g=eg:Filter(c46656406.filter,nil,tp)
	-- 将连锁对象设置为所有特殊召唤成功的怪兽
	Duel.SetTargetCard(eg)
	-- 设置破坏效果的操作信息，目标为符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置抽卡效果的操作信息，目标为使用者，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 筛选出与当前效果相关且由对方从卡组特殊召唤的怪兽
function c46656406.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 执行效果：破坏符合条件的怪兽并抽一张卡
function c46656406.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c46656406.filter2,nil,e,tp)
	-- 判断是否有怪兽被成功破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 让使用者从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
