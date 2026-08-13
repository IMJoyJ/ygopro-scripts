--精霊神后 ドリアード
-- 效果：
-- 这张卡不能通常召唤。自己·对方的墓地的怪兽属性是6种类以上的场合才能特殊召唤。
-- ①：这张卡的攻击力·守备力上升自己·对方的墓地的怪兽的属性种类×500。
-- ②：对方把怪兽特殊召唤之际，把自己墓地3只怪兽除外才能发动。那次特殊召唤无效，那些怪兽破坏。
function c32965616.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己·对方的墓地的怪兽属性是6种类以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己·对方的墓地的怪兽属性是6种类以上的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c32965616.spcon)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力·守备力上升自己·对方的墓地的怪兽的属性种类×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c32965616.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 对方把怪兽特殊召唤之际，把自己墓地3只怪兽除外才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32965616,0))
	e5:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_SPSUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c32965616.discon)
	e5:SetCost(c32965616.discost)
	e5:SetTarget(c32965616.distg)
	e5:SetOperation(c32965616.disop)
	c:RegisterEffect(e5)
end
-- 判断这张卡是否满足从手牌特殊召唤的条件：自己主要怪兽区有空位，且双方墓地的怪兽属性种类数达到6种以上。
function c32965616.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否还有可用的主要怪兽区，若无空位则不能进行特殊召唤，返回false以阻止这次特殊召唤手续。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 获取双方墓地的所有怪兽卡，用于后续统计属性种类数。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)>=6
end
-- 计算这张卡的攻击力上升数值：统计双方墓地怪兽的属性种类数并乘以500。
function c32965616.atkval(e,c)
	-- 获取双方墓地的所有怪兽卡，用于统计属性种类数以计算攻守上升值。
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)*500
end
-- ②效果的发动条件判定：仅在对方进行特殊召唤之际且当前连锁为空时，才允许发动。
function c32965616.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件：特殊召唤的玩家不是自己（即对方特殊召唤），且当前没有其他连锁在结算中，确保是在特殊召唤之际即时发动。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 定义代价筛选函数：选择自己墓地里可以被除外作为代价的怪兽卡。
function c32965616.discfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 执行②效果发动代价：从自己墓地选择3只怪兽除外；chk==0时只检查是否存在足够代价。
function c32965616.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己墓地是否存在至少3只满足除外条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32965616.discfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 弹出选择提示，告知玩家需要选择要除外的卡片，并准备选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择3只符合条件的怪兽作为发动代价，并将这些卡设置为代价对象。
	local g=Duel.SelectMatchingCard(tp,c32965616.discfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选择的3张怪兽卡以表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标设定：该效果不取对象，直接对正在特殊召唤的怪兽群生效；登记无效召唤与破坏的操作信息。
function c32965616.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次操作包含“无效特殊召唤”的分类，目标为当前正在特殊召唤的那些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 向系统登记本次操作包含“破坏”的分类，目标为当前正在特殊召唤的那些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- ②效果处理：将对方的那次特殊召唤无效，并将那些怪兽破坏。
function c32965616.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前正在进行的特殊召唤无效，阻止那些怪兽特殊召唤成功。
	Duel.NegateSummon(eg)
	-- 将因特殊召唤无效而被除去的那些怪兽立即破坏送去墓地，破坏原因记为效果破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
