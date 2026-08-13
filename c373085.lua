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
-- 作为效果①的发动条件判定与目标处理：计算对方场上卡片数，检查对方卡组是否有足够卡片且能送墓，并登记从对方卡组顶送墓该数量卡片的操作信息。
function c373085.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上（怪兽区域和魔法陷阱区域）的卡总数，作为本次从卡组顶送去墓地的卡数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 在发动时点的合法性检查（chk==0）：要求对方场上有卡、对方卡组张数不少于该数量、且对方玩家可以将卡组顶相应张数送去墓地，全部满足才可发动。
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=ct and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	-- 登记效果处理时将对方卡组顶 ct 张卡送去墓地的操作信息（CATEGORY_DECKDES），供后续处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
-- 效果①的处理函数：执行时将对方场上卡数量重新计算，然后从对方卡组顶将对应数量的卡送去墓地。
function c373085.disop1(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上卡总数作为送墓数量（处理时点可能发生变化）。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 以效果原因将对方卡组最上方 ct 张卡送去墓地。
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
-- 作为效果②的发动条件判定与目标处理：计算对方场上卡片数，检查自己卡组是否有足够卡片且能送墓，并登记从自己卡组顶送墓该数量卡片的操作信息。
function c373085.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡总数，作为②效果要送去墓地的卡数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 在发动时点的合法性检查（chk==0）：要求对方场上有卡、自己卡组张数不少于该数量、且自己可以将卡组顶相应张数送去墓地，全部满足才可发动。
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 登记效果处理时将我方卡组顶 ct 张卡送去墓地的操作信息（CATEGORY_DECKDES），target_player 为 tp（自己）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 效果②的处理函数：执行时将对方场上卡数量重新计算，然后从自己卡组顶将对应数量的卡送去墓地。
function c373085.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上卡总数作为送墓数量（处理时点可能发生变化）。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 以效果原因将自己卡组最上方 ct 张卡送去墓地。
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	end
end
