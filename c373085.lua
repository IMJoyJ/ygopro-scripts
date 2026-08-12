--讃美火
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。把对方场上的卡数量的卡从对方卡组上面送去墓地。
-- ②：这张卡特殊召唤的场合才能发动。把对方场上的卡数量的卡从自己卡组上面送去墓地。
function c373085.initial_effect(c)
	-- ①：这张卡召唤时才能发动。把对方场上的卡数量的卡从对方卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(373085,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c373085.distg1)
	e1:SetOperation(c373085.disop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(373085,1))
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,373085)
	e2:SetTarget(c373085.distg2)
	e2:SetOperation(c373085.disop2)
	c:RegisterEffect(e2)
end
-- 检查是否满足效果发动条件：对方场上的卡数量大于0，且对方卡组数量不少于该数量，以及对方可以将该数量的卡从卡组送去墓地。
function c373085.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上卡的数量作为要处理的卡数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 若满足发动条件，则返回true，表示可以发动此效果。
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=ct and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	-- 设置连锁操作信息：将对方卡组顶部的指定数量的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
-- ①：这张卡召唤时才能发动。把对方场上的卡数量的卡从对方卡组上面送去墓地。
function c373085.disop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上卡的数量作为要处理的卡数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 将对方卡组顶部的指定数量的卡以效果原因送去墓地。
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
-- ②：这张卡特殊召唤的场合才能发动。把对方场上的卡数量的卡从自己卡组上面送去墓地。
function c373085.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上卡的数量作为要处理的卡数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 若满足发动条件，则返回true，表示可以发动此效果。
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置连锁操作信息：将己方卡组顶部的指定数量的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- ②：这张卡特殊召唤的场合才能发动。把对方场上的卡数量的卡从自己卡组上面送去墓地。
function c373085.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上卡的数量作为要处理的卡数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 将己方卡组顶部的指定数量的卡以效果原因送去墓地。
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	end
end
