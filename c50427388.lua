--暴走する魔力
-- 效果：
-- 自己墓地的魔法卡全部从游戏中除外才能发动。持有除外的魔法卡数量×300的数值以下的守备力的对方场上表侧表示存在的怪兽全部破坏。
function c50427388.initial_effect(c)
	-- 自己墓地的魔法卡全部从游戏中除外才能发动。持有除外的魔法卡数量×300的数值以下的守备力的对方场上表侧表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50427388.cost)
	e1:SetTarget(c50427388.target)
	e1:SetOperation(c50427388.activate)
	c:RegisterEffect(e1)
end
-- 代价函数：通过标签记录已通过代价检查并返回true，实际除外墓地魔法卡的代价操作推迟到目标选择时执行。
function c50427388.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：筛选自己墓地里满足“魔法卡且能够被除外”的卡，作为代价除外的候选。
function c50427388.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 过滤函数：筛选对方场上表侧表示且守备力不高于指定数值def的怪兽，作为破坏对象候选。
function c50427388.filter(c,def)
	return c:IsFaceup() and c:IsDefenseBelow(def)
end
-- 目标函数：发动时先检查是否已通过代价且存在符合条件的对象；确定发动后将墓地全部可除外魔法卡除外作为代价，把除外数量×300存入标签，并选出应破坏的对方怪兽登记到操作信息。
function c50427388.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 计算自己墓地中可作为代价除外的魔法卡数量ct。
		local ct=Duel.GetMatchingGroupCount(c50427388.cfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查对方场上是否存在至少1只表侧表示且守备力不超过ct×300的怪兽，以此判断效果是否满足发动条件。
		return Duel.IsExistingMatchingCard(c50427388.filter,tp,0,LOCATION_MZONE,1,nil,ct*300)
	end
	-- 获取自己墓地中所有可作为代价除外的魔法卡，构成代价卡组g。
	local g=Duel.GetMatchingGroup(c50427388.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将选中的墓地魔法卡全部从游戏中除外，作为发动本效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount()*300)
	-- 以除外数量×300作为守备力上限，获取对方场上所有符合条件的表侧表示怪兽作为破坏对象。
	local sg=Duel.GetMatchingGroup(c50427388.filter,tp,0,LOCATION_MZONE,nil,g:GetCount()*300)
	-- 把即将进行的破坏操作的信息（分类为破坏、目标为sg、数量为sg数量）登记到连锁处理中，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：按照效果发动时确定的守备力阈值，选择对方场上符合条件的表侧表示怪兽并全部破坏。
function c50427388.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新筛选对方场上表侧表示且守备力不超过e:GetLabel()（即除外魔法卡数×300）的怪兽。
	local sg=Duel.GetMatchingGroup(c50427388.filter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 将这些选中的怪兽以效果破坏送入墓地。
	Duel.Destroy(sg,REASON_EFFECT)
end
