--夙めてはしろ 二人ではしろ
-- 效果：
-- ①：自己的场上（表侧表示）·墓地·除外状态的其中每种都没有「清晨一片雪白色 两人一同雪中行」存在的场合，从自己卡组上面把7张卡里侧除外才能发动。对方必须从自身的卡组上面·额外卡组把合计7张卡里侧除外。
local s,id,o=GetID()
-- 创建效果，设置为发动时可选择的自由连锁效果，需要满足条件、支付费用、进行处理
function s.initial_effect(c)
	-- ①：自己的场上（表侧表示）·墓地·除外状态的其中每种都没有「清晨一片雪白色 两人一同雪中行」存在的场合
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件，即自己场上、墓地、除外区中不存在「清晨一片雪白色 两人一同雪中行」
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上、墓地、除外区中是否存在「清晨一片雪白色 两人一同雪中行」
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,id)
end
-- 支付费用，从自己卡组最上方除外7张卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方7张卡
	local g=Duel.GetDecktopGroup(tp,7)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==7 end
	-- 禁止在除外卡组卡时自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将获取的卡组最上方7张卡以里侧表示除外作为费用
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 获取对方卡组最上方可除外的卡组，用于后续处理
function s.getrmdg(tp)
	local cg=Group.CreateGroup()
	for ct=1,7 do
		-- 获取对方卡组最上方ct张卡
		local g=Duel.GetDecktopGroup(1-tp,ct)
		if not g:FilterCount(Card.IsAbleToRemove,nil,1-tp,POS_FACEDOWN,REASON_RULE)==ct then break end
		cg=g
	end
	return cg
end
-- 设置效果目标，判断对方是否能除外足够数量的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=s.getrmdg(tp)
	-- 获取对方额外卡组中可除外的卡的数量
	local ct1=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	local ct2=rg:GetCount()
	if chk==0 then return ct1+ct2>=7 end
	-- 设置操作信息，表示将要除外7张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,7,0,LOCATION_EXTRA+LOCATION_DECK)
end
-- 发动效果，处理对方除外卡组和额外卡组的卡
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以除外卡
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	local dg=s.getrmdg(tp)
	-- 获取对方额外卡组中可除外的卡
	local edg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	local ct1=dg:GetCount()
	local ct2=edg:GetCount()
	if ct1+ct2<7 then return end
	-- 提示玩家选择要除外的额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"选择除外的额外卡组的卡（取消的场合除外7张卡组的卡）"
	local sg=edg:CancelableSelect(1-tp,7-ct1,7,nil)
	-- 获取对方卡组最上方7张卡
	local rsg=Duel.GetDecktopGroup(1-tp,7)
	if sg then
		-- 将选择的卡以里侧表示除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
		-- 重新获取对方卡组最上方剩余的卡
		rsg=Duel.GetDecktopGroup(1-tp,7-sg:GetCount())
	end
	if rsg:GetCount()>0 then
		-- 禁止在除外卡组卡时自动洗切卡组
		Duel.DisableShuffleCheck()
		-- 将剩余的卡以里侧表示除外
		Duel.Remove(rsg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
