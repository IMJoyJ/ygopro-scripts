--アーティファクト－デュランダル
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，可以从以下效果选择1个发动。这个效果在对方回合也能发动。
-- ●在场上的怪兽的效果发动时或者在通常魔法·通常陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个效果变成「选对方场上1张魔法·陷阱卡破坏」。
-- ●把这张卡1个超量素材取除才能发动。双方让手卡全部回到卡组洗切。那之后，双方各自从卡组抽出自身回到卡组的数量。
function c69840739.initial_effect(c)
	-- 添加XYZ召唤手续：5星怪兽2只
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ●在场上的怪兽的效果发动时或者在通常魔法·通常陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个效果变成「选对方场上1张魔法·陷阱卡破坏」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69840739,0))  --"效果变化"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c69840739.chcon)
	e1:SetCost(c69840739.cost)
	e1:SetTarget(c69840739.chtg)
	e1:SetOperation(c69840739.chop)
	c:RegisterEffect(e1)
	-- ●把这张卡1个超量素材取除才能发动。双方让手卡全部回到卡组洗切。那之后，双方各自从卡组抽出自身回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69840739,1))  --"手卡扰乱"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c69840739.cost)
	e2:SetTarget(c69840739.drtg)
	e2:SetOperation(c69840739.drop)
	c:RegisterEffect(e2)
end
-- 效果1（效果变化）的发动条件函数：场上的怪兽效果发动时，或者通常魔法、通常陷阱卡发动时
function c69840739.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前发动效果的卡片在发动时的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE)
		or ((re:GetActiveType()==TYPE_SPELL or re:GetActiveType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果发动的Cost函数：取除这张卡的1个超量素材
function c69840739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家提示选择发动了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果1的目标检查函数：检查对方场上是否存在魔法·陷阱卡
function c69840739.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查被改变效果的玩家（即发动该效果的玩家）的对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69840739.filter,rp,0,LOCATION_ONFIELD,1,nil) end
end
-- 效果1的效果处理函数：将该连锁的效果处理替换为破坏魔陷的效果
function c69840739.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空该连锁的对象卡片组（因为新效果不取对象）
	Duel.ChangeTargetCard(ev,g)
	-- 将该连锁的效果处理函数替换为指定的破坏魔陷函数
	Duel.ChangeChainOperation(ev,c69840739.repop)
end
-- 过滤条件：魔法或陷阱卡
function c69840739.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 替换后的效果处理函数：选对方场上1张魔法·陷阱卡破坏
function c69840739.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c69840739.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果2（手卡洗回抽卡）的发动检查函数：检查双方手卡情况以及是否能洗回卡组并抽卡
function c69840739.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡数量
	local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 获取对方手卡数量
	local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 检查自己是否可以抽卡（若手卡为0则无需抽卡，视为可行）
	if chk==0 then return (Duel.IsPlayerCanDraw(tp) or h1==0)
		-- 检查对方是否可以抽卡（若手卡为0则无需抽卡，视为可行）
		and (Duel.IsPlayerCanDraw(1-tp) or h2==0)
		-- 检查双方手卡中是否存在至少1张可以回到卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,LOCATION_HAND,1,nil) end
	-- 设置操作信息：将双方手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_HAND)
	-- 设置操作信息：双方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果2的效果处理函数：双方手卡全部回到卡组洗切，之后各自抽出回到卡组的数量
function c69840739.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方的所有手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	-- 将双方手卡送回卡组并洗切，若成功送回至少1张则继续处理
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		local og=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
		-- 若有自己的卡回到卡组，则洗切自己的卡组
		if og:IsExists(Card.IsControler,1,nil,tp) then Duel.ShuffleDeck(tp) end
		-- 若有对方的卡回到卡组，则洗切对方的卡组
		if og:IsExists(Card.IsControler,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
		-- 中断当前效果，使之后的效果处理（抽卡）不与回卡组视为同时处理
		Duel.BreakEffect()
		local ct1=og:FilterCount(Card.IsPreviousControler,nil,tp)
		local ct2=og:FilterCount(Card.IsPreviousControler,nil,1-tp)
		-- 自己从卡组抽出自身回到卡组的数量
		Duel.Draw(tp,ct1,REASON_EFFECT)
		-- 对方从卡组抽出自身回到卡组的数量
		Duel.Draw(1-tp,ct2,REASON_EFFECT)
	end
end
