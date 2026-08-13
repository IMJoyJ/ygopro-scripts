--天よりの宝札
-- 效果：
-- ①：把自己的手卡·场上的卡全部除外才能发动。自己直到手卡变成2张为止从卡组抽卡。
function c42664989.initial_effect(c)
	-- ①：把自己的手卡·场上的卡全部除外才能发动。自己直到手卡变成2张为止从卡组抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42664989.cost)
	e1:SetTarget(c42664989.target)
	e1:SetOperation(c42664989.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：生成己方手牌和场上的全部卡组，确认存在卡且均可作为除外代价后，将其全部表侧表示除外。
function c42664989.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方手牌和场上除自身以外所有卡作为代价候选组。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 and g:GetCount()==g:FilterCount(Card.IsAbleToRemoveAsCost,nil) end
	-- 将候选组全部表侧表示除外，作为效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标函数：确认可以抽卡后，将对象玩家设为自己，设定需要抽至手牌为2张的差额，并登记抽卡效果的操作信息。
function c42664989.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段，确认发动玩家当前可以抽卡，否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp) end
	-- 统计发动玩家当前手牌数，用于计算需要抽至2张的差额。
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 将连锁的对象玩家设定为发动玩家自己。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设定为需要抽的卡数（2-当前手牌数）。
	Duel.SetTargetParam(2-ht)
	-- 登记操作信息：本连锁为抽卡效果，目标玩家为tp，参数为2-ht，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2-ht)
end
-- 效果处理函数：取得目标玩家及其当前手牌数，若手牌不足2张则从卡组抽卡补足至2张。
function c42664989.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁发动时记录的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得目标玩家当前手牌数，用于判断是否不足2张。
	local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ht<2 then
		-- 令目标玩家从卡组抽2-ht张牌，直到手牌变为2张，抽卡原因标识为效果。
		Duel.Draw(p,2-ht,REASON_EFFECT)
	end
end
