--ライトロード・セイント ミネルバ
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从自己卡组上面把3张卡送去墓地。那之中有「光道」卡的场合，再让自己抽出那个数量。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己卡组上面把3张卡送去墓地。那之中有「光道」卡的场合，可以再把最多有那个数量的场上的卡破坏。
function c30100551.initial_effect(c)
	-- 为密涅瓦添加XYZ召唤手续，使其可用任意2只等级4的怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从自己卡组上面把3张卡送去墓地。那之中有「光道」卡的场合，再让自己抽出那个数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30100551,1))  --"送去墓地并抽卡"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,30100551)
	e1:SetCost(c30100551.drcost)
	e1:SetTarget(c30100551.distg)
	e1:SetOperation(c30100551.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己卡组上面把3张卡送去墓地。那之中有「光道」卡的场合，可以再把最多有那个数量的场上的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30100551,2))  --"送去墓地并破坏"
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,30100552)
	e2:SetCondition(c30100551.descon)
	e2:SetTarget(c30100551.distg)
	e2:SetOperation(c30100551.desop)
	c:RegisterEffect(e2)
end
-- 发动①效果的代价：确认这张卡有1个超量素材可移除，然后移除1个超量素材作为发动代价。
function c30100551.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动条件和目标设定：确认可以从自己卡组顶将3张卡送去墓地，并记录对象玩家为自己、参数为3，同时设置“从卡组送墓”的操作信息。
function c30100551.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者是否可以从卡组顶端将3张卡送去墓地，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 将当前连锁的对象玩家设置为发动者自身，供后续效果处理时获取。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为3，表示要送去墓地的卡牌数量。
	Duel.SetTargetParam(3)
	-- 设置操作信息：本次效果包含从卡组送墓3张卡的处理（目标玩家为自己，数量为3）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 过滤器：判断一张卡是否为「光道」卡且位于墓地，用于统计堆墓结果中光道卡的数量。
function c30100551.cfilter(c)
	return c:IsSetCard(0x38) and c:IsLocation(LOCATION_GRAVE)
end
-- ①效果的处理：从对方/自己卡组顶丢弃3张卡，统计其中光道卡数量；若大于0，则中断当前效果后，让发动者抽等数量的卡。
function c30100551.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出此前设定的对象玩家和对象参数，即自己与3。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将玩家p的卡组顶端d张卡以效果原因送去墓地，实际执行堆墓操作。
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	-- 获取刚才被送去墓地的卡片组，以便统计其中「光道」卡的数量。
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c30100551.cfilter,nil)
	if ct>0 then
		-- 中断当前效果，使后续的抽卡或破坏处理与前面的堆墓处理不在同一时点连续处理，避免错过时点。
		Duel.BreakEffect()
		-- 让发动者从卡组抽ct张卡，ct为刚才送入墓地的「光道」卡的数量。
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被战斗破坏，或者被对方的效果破坏且破坏前控制权属于自己时才能发动。
function c30100551.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- ②效果的处理：从卡组顶丢弃3张卡，统计其中光道卡数量；若数量不为0且场上有卡，由玩家选择是否破坏，然后选1到ct张场上的卡破坏。
function c30100551.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出此前设定的对象玩家和对象参数，即自己与3。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将玩家p的卡组顶端d张卡以效果原因送去墓地，实际执行堆墓操作。
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	-- 获取刚才被送去墓地的卡片组，以便统计其中「光道」卡的数量。
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c30100551.cfilter,nil)
	-- 获取双方场上的所有卡（怪兽区和魔法陷阱区）作为可被破坏的候选对象。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 若堆墓结果中有光道卡且场上有可破坏的卡，并且玩家选择“是”，则进入后续选卡破坏处理。
	if ct~=0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(30100551,0)) then  --"是否选场上的卡破坏？"
		-- 中断当前效果，使后续的破坏处理与前面的堆墓处理分离开来。
		Duel.BreakEffect()
		-- 向玩家显示选择提示，要求选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sdg=dg:Select(tp,1,ct,nil)
		-- 将选中的卡组高亮显示为选择对象，并记录这些卡为对象。
		Duel.HintSelection(sdg)
		-- 将选中的卡片以效果原因破坏。
		Duel.Destroy(sdg,REASON_EFFECT)
	end
end
