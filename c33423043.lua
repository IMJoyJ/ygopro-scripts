--異次元の指名者
-- 效果：
-- 宣言1张卡的名称。确认对方手卡，若被宣言的卡在对方手卡中存在，则将其中1张被宣言的卡从游戏中除外；若被宣言的卡未在对方手卡中存在，则自己随机从游戏中除外1张手卡。
function c33423043.initial_effect(c)
	-- 宣言1张卡的名称。确认对方手卡，若被宣言的卡在对方手卡中存在，则将其中1张被宣言的卡从游戏中除外；若被宣言的卡未在对方手卡中存在，则自己随机从游戏中除外1张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetTarget(c33423043.target)
	e1:SetOperation(c33423043.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件，即自己手牌数量大于0且对方手牌中存在至少1张卡。
function c33423043.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查对方手牌中是否存在至少1张卡。
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要宣言的卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一张卡的卡号。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号设置为当前效果的目标参数。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为宣言卡名。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理函数，根据宣言的卡是否存在于对方手牌中执行不同操作。
function c33423043.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中目标参数的值，即玩家宣言的卡号。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取对方手牌中所有与宣言卡号相同的卡组成的组。
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	-- 获取玩家手牌的全部卡片组。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 确认玩家手牌内容。
	Duel.ConfirmCards(tp,hg)
	if g:GetCount()>0 then
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡从游戏中除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 将对方手牌洗切。
		Duel.ShuffleHand(1-tp)
	else
		-- 获取玩家手牌的全部卡片组。
		local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local dg=sg:RandomSelect(tp,1)
		-- 将随机选中的卡从游戏中除外。
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
		-- 将对方手牌洗切。
		Duel.ShuffleHand(1-tp)
	end
end
