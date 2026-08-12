--夙めてはしろ 二人ではしろ
-- 效果：
-- ①：自己的场上（表侧表示）·墓地·除外状态的其中每种都没有「清晨一片雪白色 两人一同雪中行」存在的场合，从自己卡组上面把7张卡里侧除外才能发动。对方必须从自身的卡组上面·额外卡组把合计7张卡里侧除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册一个以对方玩家为对象的自由时点除外类魔法·陷阱发动效果，并设定其条件、代价、目标与处理函数
function s.initial_effect(c)
	-- ①：自己的场上（表侧表示）·墓地·除外状态的其中每种都没有「清晨一片雪白色 两人一同雪中行」存在的场合，从自己卡组上面把7张卡里侧除外才能发动。对方必须从自身的卡组上面·额外卡组把合计7张卡里侧除外。
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
-- 发动条件函数：检查自己的场上·墓地·除外状态是否均不存在同名卡
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上（表侧表示）·墓地·除外区是否存在「清晨一片雪白色 两人一同雪中行」，存在的场合则不能发动
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,id)
end
-- 代价函数：确认卡组最上方7张卡都能里侧除外后，将其作为发动代价里侧除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己卡组最上方的7张卡
	local g=Duel.GetDecktopGroup(tp,7)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==7 end
	-- 使接下来从卡组最上方取卡的操作不触发卡组洗切检测
	Duel.DisableShuffleCheck()
	-- 把自己卡组最上方的7张卡里侧除外，作为发动的代价
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 计算对方卡组最上方最多有多少张可以被里侧除外（最多7张），返回该卡片组
function s.getrmdg(tp)
	local cg=Group.CreateGroup()
	for ct=1,7 do
		-- 取得对方卡组最上方的ct张卡
		local g=Duel.GetDecktopGroup(1-tp,ct)
		if g:FilterCount(Card.IsAbleToRemove,nil,1-tp,POS_FACEDOWN,REASON_RULE)~=ct then break end
		cg=g
	end
	return cg
end
-- 目标函数：确认对方卡组与额外卡组中可里侧除外的卡合计在7张以上，并设置除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=s.getrmdg(tp)
	-- 计算对方额外卡组中可以被里侧除外的卡的数量
	local ct1=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	local ct2=rg:GetCount()
	if chk==0 then return ct1+ct2>=7 end
	-- 设置操作信息：本次处理将从卡组·额外卡组把7张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,7,0,LOCATION_EXTRA+LOCATION_DECK)
end
-- 效果处理函数：让对方从额外卡组选择要里侧除外的卡，不足7张的部分从卡组最上方里侧除外
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家是否能够除外卡，不能则中止处理
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	local dg=s.getrmdg(tp)
	-- 取得对方额外卡组中所有可以被里侧除外的卡
	local edg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	local ct1=dg:GetCount()
	local ct2=edg:GetCount()
	if ct1+ct2<7 then return end
	-- 向发动方提示选择信息：选择除外的额外卡组的卡（取消的场合除外7张卡组的卡）
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"选择除外的额外卡组的卡（取消的场合除外7张卡组的卡）"
	local sg=edg:CancelableSelect(1-tp,7-ct1,7,nil)
	-- 默认取对方卡组最上方的7张卡作为待除外对象（对方未选择额外卡组的卡时使用）
	local rsg=Duel.GetDecktopGroup(1-tp,7)
	if sg then
		-- 将对方选择的额外卡组的卡里侧除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
		-- 对方选择了额外卡组的卡的场合，从卡组最上方取补足到合计7张所需的卡
		rsg=Duel.GetDecktopGroup(1-tp,7-sg:GetCount())
	end
	if rsg:GetCount()>0 then
		-- 使接下来从卡组最上方取卡的操作不触发卡组洗切检测
		Duel.DisableShuffleCheck()
		-- 将对方卡组最上方的剩余卡里侧除外，使合计除外7张
		Duel.Remove(rsg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
