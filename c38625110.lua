--夙めてはしろ 二人ではしろ
-- 效果：
-- ①：自己的场上（表侧表示）·墓地·除外状态的其中每种都没有「清晨一片雪白色 两人一同雪中行」存在的场合，从自己卡组上面把7张卡里侧除外才能发动。对方必须从自身的卡组上面·额外卡组把合计7张卡里侧除外。
local s,id,o=GetID()
-- 注册卡片发动的判定、去除自己卡组顶7张作为Cost里侧除外、并迫使对方从卡组/额外卡组里侧除外7张卡的效果
function s.initial_effect(c)
	-- ①：自己场上（表侧表示）·墓地·除外状态的其中每种都没有「清晨一片雪白色 两人一同雪中行」存在的场合，从自己卡组上面把7张卡里侧表示除外才能发动。对方必须从自身的卡组上面·额外卡组把合计7张卡里侧表示除外。
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
-- 检查自己场上、墓地和除外状态是否均没有此卡的任何存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 如果没有此卡的存在则符合发动的前置条件
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,id)
end
-- 从自己卡组顶将7张卡片里侧表示除外作为发动的代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的7张卡片
	local g=Duel.GetDecktopGroup(tp,7)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==7 end
	-- 暂时停用系统在卡片移动时的自动洗牌检测
	Duel.DisableShuffleCheck()
	-- 将获取的这7张卡片以里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 计算对方卡组顶最多有多少张卡能够被里侧表示除外（最多7张）
function s.getrmdg(tp)
	local cg=Group.CreateGroup()
	for ct=1,7 do
		-- 获取对方卡组顶指定数量的卡片
		local g=Duel.GetDecktopGroup(1-tp,ct)
		if g:FilterCount(Card.IsAbleToRemove,nil,1-tp,POS_FACEDOWN,REASON_RULE)~=ct then break end
		cg=g
	end
	return cg
end
-- 魔法卡发动时的可行性检查与数量核算
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=s.getrmdg(tp)
	-- 计算对方额外卡组中能够里侧表示除外的卡片数量
	local ct1=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	local ct2=rg:GetCount()
	if chk==0 then return ct1+ct2>=7 end
	-- 设置操作信息为将对方卡组或额外卡组的卡片里侧表示除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,7,0,LOCATION_EXTRA+LOCATION_DECK)
end
-- 迫使对方从卡组最上方或额外卡组中选择并里侧表示除外合计7张卡片的效果执行
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家当前是否受到禁止除外卡片的影响，若是则停止处理
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	local dg=s.getrmdg(tp)
	-- 获取对方额外卡组中所有符合里侧除外条件的卡片组
	local edg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	local ct1=dg:GetCount()
	local ct2=edg:GetCount()
	if ct1+ct2<7 then return end
	-- 向对方玩家发送提示，请选择需要从额外卡组除外的卡片（不够的由卡组顶卡片补充）
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"选择除外的额外卡组的卡（取消的场合除外7张卡组的卡）"
	local sg=edg:CancelableSelect(1-tp,7-ct1,7,nil)
	-- 默认获取对方卡组顶最上方的7张卡片以备用
	local rsg=Duel.GetDecktopGroup(1-tp,7)
	if sg then
		-- 将对方主动从额外卡组选出的卡片里侧表示除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
		-- 根据额外卡组已除外的数量，计算仍需从卡组顶里侧除外的剩余数量
		rsg=Duel.GetDecktopGroup(1-tp,7-sg:GetCount())
	end
	if rsg:GetCount()>0 then
		-- 为处理卡组顶卡片移动，再次关闭自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 将对方卡组顶剩余的卡片全部以里侧表示除外
		Duel.Remove(rsg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
