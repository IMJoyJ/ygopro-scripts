--ライトロード・セイント ミネルバ
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从自己卡组上面把3张卡送去墓地。那之中有「光道」卡的场合，再让自己抽出那个数量。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己卡组上面把3张卡送去墓地。那之中有「光道」卡的场合，可以再把最多有那个数量的场上的卡破坏。
function c30100551.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4且数量为2的怪兽进行叠放
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
-- 支付效果代价，从自己场上取除1个超量素材
function c30100551.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标，检查玩家是否可以将卡组顶端3张卡送去墓地
function c30100551.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组顶端3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为3
	Duel.SetTargetParam(3)
	-- 设置连锁操作信息，表示将从卡组送去墓地3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 定义过滤函数，用于判断卡片是否为「光道」卡且在墓地
function c30100551.cfilter(c)
	return c:IsSetCard(0x38) and c:IsLocation(LOCATION_GRAVE)
end
-- 处理效果发动，将卡组顶端3张卡送去墓地，若其中有「光道」卡则抽卡
function c30100551.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将目标玩家卡组顶端3张卡送去墓地
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	-- 获取实际操作的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c30100551.cfilter,nil)
	if ct>0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 让当前玩家抽卡，数量为「光道」卡的数量
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
-- 设置效果发动条件，判断此卡是否因战斗或对方效果被破坏
function c30100551.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 处理效果发动，将卡组顶端3张卡送去墓地，若其中有「光道」卡则可选择破坏场上的卡
function c30100551.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将目标玩家卡组顶端3张卡送去墓地
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	-- 获取实际操作的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c30100551.cfilter,nil)
	-- 获取场上所有卡片的集合
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 判断是否有「光道」卡且场上有卡可破坏，并询问玩家是否选择破坏
	if ct~=0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(30100551,0)) then  --"是否选场上的卡破坏？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sdg=dg:Select(tp,1,ct,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(sdg)
		-- 破坏选中的卡
		Duel.Destroy(sdg,REASON_EFFECT)
	end
end
