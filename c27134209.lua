--樹冠の甲帝ベアグラム
-- 效果：
-- 这张卡不能通常召唤。把自己的手卡·墓地3只昆虫族·植物族怪兽除外的场合才能从手卡·墓地特殊召唤。自己对「树冠之甲帝 比亚格拉姆」1回合只能有1次特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方不能对应自己的魔法·陷阱卡的效果的发动把怪兽的效果发动。
-- ②：1回合1次，自己主要阶段才能发动。昆虫族·植物族怪兽以外的场上的表侧表示怪兽全部破坏。这个回合，这张卡不能直接攻击。
function c27134209.initial_effect(c)
	c:SetSPSummonOnce(27134209)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己的手卡·墓地3只昆虫族·植物族怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 把自己的手卡·墓地3只昆虫族·植物族怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c27134209.sprcon)
	e1:SetTarget(c27134209.sprtg)
	e1:SetOperation(c27134209.sprop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能对应自己的魔法·陷阱卡的效果的发动把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c27134209.chainop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。昆虫族·植物族怪兽以外的场上的表侧表示怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c27134209.destg)
	e3:SetOperation(c27134209.desop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤素材的筛选条件：卡须为昆虫族或植物族怪兽，且可以作为除外的代价。
function c27134209.sprfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续的发动条件：c为空时判定放行；否则需要己方主要怪兽区有空位，且手卡·墓地存在至少3张满足sprfilter的卡（不包含要特召的c）。
function c27134209.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方场上主要怪兽区是否有空格，确保特殊召唤有可用区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方手卡和墓地是否至少有3张满足sprfilter的怪兽卡（不包含c），用于作为除外费用。
		and Duel.IsExistingMatchingCard(c27134209.sprfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,3,c)
end
-- 处理特殊召唤手续的选择：从候选组中让玩家选择3张要除外的昆虫族·植物族怪兽；选择成功后保存并返回true，取消则返回false。
function c27134209.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取己方手卡·墓地中所有满足sprfilter的怪兽卡（不含c），作为候选集合。
	local g=Duel.GetMatchingGroup(c27134209.sprfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 显示选择提示，引导玩家选择要除外的卡（提示文本为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤手续：取出之前保存的选择组并将其除外，然后删除该组引用。
function c27134209.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以表侧表示除外，除外原因为特殊召唤（作为召唤手续消耗）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 监听效果发动事件：若发动的是己方（ep==tp）的魔法·陷阱卡效果，则设置后续连锁限制函数。
function c27134209.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and ep==tp then
		-- 设置连锁限制条件，使之后对手不能以怪兽效果连锁己方发动的魔法·陷阱卡效果。
		Duel.SetChainLimit(c27134209.chainlm)
	end
end
-- 定义连锁限制函数：己方（tp==rp）可以任意连锁；对方连锁时若该效果是怪兽效果则不允许，从而禁止对方用怪兽效果对应自己的魔法·陷阱卡。
function c27134209.chainlm(re,rp,tp)
	return tp==rp or not re:IsActiveType(TYPE_MONSTER)
end
-- 定义破坏对象筛选条件：卡片为表侧表示，且不是昆虫族或植物族怪兽。
function c27134209.desfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_INSECT+RACE_PLANT)
end
-- 效果发动的目标判定：检查场上是否存在符合条件的怪兽；若存在则取得全部符合条件的怪兽并设置破坏的操作信息。
function c27134209.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：场上是否存在至少1只表侧表示的非昆虫族·植物族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c27134209.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上所有表侧表示且不是昆虫族·植物族的怪兽，作为本次破坏候选（不取对象，处理时再确定）。
	local g=Duel.GetMatchingGroup(c27134209.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将破坏的对象组及数量写入连锁操作信息，供后续时点和卡片效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得场上所有符合条件的怪兽并全部破坏；若这张卡仍与效果关联，则给它附加一个“本回合不能直接攻击”的持续效果。
function c27134209.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得场上所有符合条件的怪兽（处理时实时获取对象组）。
	local g=Duel.GetMatchingGroup(c27134209.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将取得的怪兽全部破坏，破坏原因为效果。
	Duel.Destroy(g,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不能直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
