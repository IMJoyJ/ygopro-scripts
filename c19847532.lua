--ヘルフレイムエンペラー
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡上级召唤时，从自己墓地把最多5只炎属性怪兽除外才能发动。把除外数量的场上的魔法·陷阱卡破坏。
function c19847532.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡上级召唤时，从自己墓地把最多5只炎属性怪兽除外才能发动。把除外数量的场上的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19847532,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c19847532.condition)
	e2:SetTarget(c19847532.target)
	e2:SetOperation(c19847532.operation)
	c:RegisterEffect(e2)
end
-- 对应①的发动条件：仅当这张卡以表侧表示上级召唤成功时才满足时点。
function c19847532.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 破坏对象的过滤函数：选择场上表侧或里侧的魔法·陷阱卡（TYPE_SPELL+TYPE_TRAP）。
function c19847532.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 除外代价的过滤函数：选择自己墓地的炎属性怪兽，且该怪兽可以作为代价被除外。
function c19847532.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 发动合法性判定：自己场上存在至少1张可被破坏的魔法·陷阱卡，且自己墓地存在至少1只符合条件的炎属性怪兽。
function c19847532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张魔法·陷阱卡，用于决定能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19847532.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查墓地是否存在至少1只炎属性怪兽，且该怪兽可作为代价除外；两者同时满足时才能发动。
		and Duel.IsExistingMatchingCard(c19847532.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取场上所有魔法·陷阱卡作为破坏候选，并计算其数量用于限制除外数量上限。
	local dg=Duel.GetMatchingGroup(c19847532.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=dg:GetCount()
	if ct>5 then ct=5 end
	-- 提示玩家选择要除外的卡片（显示“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1到ct张满足c.filter的炎属性怪兽（ct为场上魔法·陷阱卡数量且最多5），作为发动代价。
	local rg=Duel.SelectMatchingCard(tp,c19847532.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 将选择的怪兽以表侧表示除外，除外原因为代价（REASON_COST）。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 把此次发动实际除外的数量写入连锁的目标参数，供处理阶段读取并决定破坏数量。
	Duel.SetTargetParam(rg:GetCount())
	-- 设定操作信息：本次效果处理将破坏场上的魔法·陷阱卡，候选对象为dg，数量为实际除外的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,rg:GetCount(),0,0)
end
-- 效果处理：读取记录的目标参数，选择等量的场上魔法·陷阱卡并破坏。
function c19847532.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 读取发动时保存的目标参数（即实际除外数量），作为处理阶段需要破坏的卡数。
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要破坏的魔法·陷阱卡（显示“请选择要破坏的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择恰好ct张魔法·陷阱卡（ct为之前除外的数量）。
	local g=Duel.SelectMatchingCard(tp,c19847532.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 手动高亮显示被选中的对象，作为选中的动画提示。
	Duel.HintSelection(g)
	-- 将选择的卡以效果原因（REASON_EFFECT）破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
