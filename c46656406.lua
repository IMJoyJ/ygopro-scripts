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
-- 筛选条件：怪兽的召唤玩家为对方（1-tp），且其特殊召唤前所在位置为卡组，用于判定是否为对方从卡组特殊召唤的怪兽。
function c46656406.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 发动时的目标处理：先进行合法性检查，若满足条件则筛选出符合条件的怪兽，将其设为当前连锁的对象，并登记破坏与抽卡的操作信息。
function c46656406.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：特殊召唤成功的怪兽中存在至少1只是对方从卡组特殊召唤的，且我方可以抽1张卡。
	if chk==0 then return eg:IsExists(c46656406.filter,1,nil,tp) and Duel.IsPlayerCanDraw(tp,1) end
	local g=eg:Filter(c46656406.filter,nil,tp)
	-- 将本次特殊召唤成功的怪兽组全部设为当前连锁的广义对象，用于在效果处理时追踪这些卡与效果的关联。
	Duel.SetTargetCard(eg)
	-- 登记破坏效果的操作信息：将筛选出的对方从卡组特殊召唤的怪兽组作为可能被破坏的对象，数量为g:GetCount()，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 登记抽卡效果的操作信息：我方tp将进行1次抽卡（target_param=1表示抽1张），因抽卡不预先取对象，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的再筛选：怪兽必须仍与效果e有联系，且仍满足“对方从卡组特殊召唤”的条件，以排除已离场或状态变化的怪兽。
function c46656406.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果处理：从特殊召唤成功的怪兽组eg中筛选出满足filter2的怪兽并破坏；若实际破坏了至少1只，则自己抽1张卡。
function c46656406.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c46656406.filter2,nil,e,tp)
	-- 以效果原因破坏筛选出的怪兽组g；只有当破坏成功（返回值不为0）时，才继续执行抽卡。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 发动者tp以效果原因从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
