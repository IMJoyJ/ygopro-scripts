--帝王の極致
-- 效果：
-- ①：对方把怪兽特殊召唤的场合1次，若自己场上有上级召唤的怪兽存在，可以从自己墓地把1张「帝王」魔法·陷阱卡除外，从以下选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●场上1只怪兽破坏。
-- ●场上最多2张魔法·陷阱卡破坏。
-- ●对方手卡随机1张丢弃。
-- ●场上1张里侧表示卡破坏。
-- ●场上1张卡回到卡组最上面。
-- ●场上1张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔法·陷阱卡的发动（e1）以及在魔法与陷阱区域发动效果的诱发效果（e2），并注册特殊召唤的合并延迟事件
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方把怪兽特殊召唤的场合1次，若自己场上有上级召唤的怪兽存在，可以从自己墓地把1张「帝王」魔法·陷阱卡除外，从以下选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_REMOVE|CATEGORY_TODECK|CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- 注册合并延迟事件，用于检测对方怪兽特殊召唤的场合，防止在同一时点有多个怪兽特殊召唤时重复触发
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
end
-- 效果发动的条件判断函数：对方特殊召唤了怪兽，且自己场上有上级召唤的怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤的怪兽中是否存在对方玩家召唤的怪兽，并且自己场上存在满足上级召唤条件的怪兽
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp) and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：检查怪兽是否为上级召唤（通常召唤）的方式出场
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤条件：检查墓地中是否存在可以作为cost除外的「帝王」魔法·陷阱卡
function s.costfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价的处理函数：从自己墓地把1张「帝王」魔法·陷阱卡除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张可除外的「帝王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的「帝王」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动目标的选择与检测函数：检查各分支效果是否满足发动条件，并让玩家选择其中一个未使用的分支效果发动
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查分支1（场上1只怪兽破坏）是否在本回合未选择过，且场上存在怪兽
	local b1=Duel.GetFlagEffect(tp,id+o)==0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0
	-- 检查分支2（场上最多2张魔法·陷阱卡破坏）是否在本回合未选择过，且场上存在魔法·陷阱卡
	local b2=Duel.GetFlagEffect(tp,id+o*2)==0 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 检查分支3（对方手卡随机1张丢弃）是否在本回合未选择过，且对方手卡存在可以因效果丢弃的卡
	local b3=Duel.GetFlagEffect(tp,id+o*3)==0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0,LOCATION_HAND,1,nil,REASON_EFFECT)
	-- 检查分支4（场上1张里侧表示卡破坏）是否在本回合未选择过，且场上存在里侧表示的卡
	local b4=Duel.GetFlagEffect(tp,id+o*4)==0 and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检查分支5（场上1张卡回到卡组最上面）是否在本回合未选择过，且场上存在可以回到卡组的卡
	local b5=Duel.GetFlagEffect(tp,id+o*5)==0 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检查分支6（场上1张卡除外）是否在本回合未选择过，且场上存在可以除外的卡
	local b6=Duel.GetFlagEffect(tp,id+o*6)==0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		and (b1 or b2 or b3 or b4 or b5 or b6) end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 让玩家从当前满足发动条件且本回合未选择过的分支效果中选择一个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"场上1只怪兽破坏"
		{b2,aux.Stringid(id,2),2},  --"场上最多2张魔法·陷阱卡破坏"
		{b3,aux.Stringid(id,3),3},  --"对方手卡随机丢弃1张"
		{b4,aux.Stringid(id,4),4},  --"场上1张里侧表示卡破坏"
		{b5,aux.Stringid(id,5),5},  --"场上1张卡回到卡组最上面"
		{b6,aux.Stringid(id,6),6}  --"场上1张卡除外"
	)
	e:SetLabel(op)
	-- 给玩家注册对应分支效果的Flag，标记该分支效果在本回合已被选择过
	Duel.RegisterFlagEffect(tp,id+o*op,RESET_PHASE+PHASE_END,0,1)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取场上所有的怪兽，用于设置破坏效果的操作信息
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置连锁操作信息：准备破坏场上的1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取场上所有的魔法·陷阱卡，用于设置破坏效果的操作信息
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 设置连锁操作信息：准备破坏场上的魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_HANDES_OPPO)
		Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	elseif op==4 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取场上所有的里侧表示卡，用于设置破坏效果的操作信息
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息：准备破坏场上的1张里侧表示卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==5 then
		e:SetCategory(CATEGORY_TODECK)
		-- 获取场上所有可以回到卡组的卡，用于设置回卡组效果的操作信息
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息：准备将场上的1张卡回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	elseif op==6 then
		e:SetCategory(CATEGORY_REMOVE)
		-- 获取场上所有可以除外的卡，用于设置除外效果的操作信息
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息：准备将场上的1张卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 效果处理的执行函数：根据玩家在发动时选择的分支效果，执行对应的破坏、丢弃手卡、回卡组或除外处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if not opt then return end
	if opt==1 then
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择场上1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示效果
			Duel.HintSelection(g)
			-- 将选中的怪兽用效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif opt==2 then
		-- 提示玩家选择要破坏的魔法·陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择场上最多2张魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,2,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示效果
			Duel.HintSelection(g)
			-- 将选中的魔法·陷阱卡用效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif opt==3 then
		-- 随机选择对方的1张手卡
		local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT):RandomSelect(tp,1)
		-- 选中卡片的视觉提示效果
		Duel.HintSelection(g)
		-- 将选中的对方手卡丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	elseif opt==4 then
		-- 提示玩家选择要破坏的里侧表示卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择场上1张里侧表示的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示效果
			Duel.HintSelection(g)
			-- 将选中的里侧表示卡用效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif opt==5 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家选择场上1张可以回到卡组的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示效果
			Duel.HintSelection(g)
			-- 将选中的卡回到持有者卡组最上面
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	elseif opt==6 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择场上1张可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示效果
			Duel.HintSelection(g)
			-- 将选中的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
