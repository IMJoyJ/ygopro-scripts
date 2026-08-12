--エレメントの加護
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：魔法·陷阱卡发动时，把自己场上1只表侧表示的「元素英雄」怪兽直到结束阶段除外才能发动。那个发动无效并破坏。
-- ②：自己场上有「元素英雄 地球侠」存在的场合，把墓地的这张卡除外才能发动。从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「元素英雄」怪兽无视召唤条件特殊召唤。
function c66367984.initial_effect(c)
	-- 将「元素英雄」系列（0x3008）添加至该卡片的怪兽系列列表中，以便进行系列判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：魔法·陷阱卡发动时，把自己场上1只表侧表示的「元素英雄」怪兽直到结束阶段除外才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c66367984.condition)
	e1:SetCost(c66367984.cost)
	e1:SetTarget(c66367984.target)
	e1:SetOperation(c66367984.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「元素英雄 地球侠」存在的场合，把墓地的这张卡除外才能发动。从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「元素英雄」怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,66367984)
	e2:SetCondition(c66367984.spcon)
	-- 设置效果②的发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c66367984.sptg)
	e2:SetOperation(c66367984.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数：当魔法·陷阱卡发动时，且该发动可以被无效。
function c66367984.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁中发动的卡是否为魔法或陷阱卡的发动，且该发动能否被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：自己场上表侧表示且可以作为代价除外的「元素英雄」怪兽。
function c66367984.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价处理函数：将自己场上1只表侧表示的「元素英雄」怪兽直到结束阶段暂时除外。
function c66367984.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段检查自己场上是否存在至少1只满足条件的「元素英雄」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c66367984.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己场上1只满足条件的「元素英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,c66367984.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为代价进行暂时除外，若成功除外则执行后续返回场上的延迟处理。
	if Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local rc=g:GetFirst()
		if rc:IsType(TYPE_TOKEN) then return end
		-- ①：魔法·陷阱卡发动时，把自己场上1只表侧表示的「元素英雄」怪兽直到结束阶段除外才能发动。那个发动无效并破坏。②：自己场上有「元素英雄 地球侠」存在的场合，把墓地的这张卡除外才能发动。从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「元素英雄」怪兽无视召唤条件特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetOperation(c66367984.retop)
		-- 注册在结束阶段将除外怪兽返回场上的延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段将暂时除外的怪兽返回场上的效果处理函数。
function c66367984.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将之前暂时除外的怪兽返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- 效果①的靶向与发动准备函数：设置无效与破坏的操作信息。
function c66367984.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：使该魔法·陷阱卡的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为：破坏该魔法·陷阱卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理（发动）函数：使发动无效并破坏。
function c66367984.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该卡的发动无效，且该卡在连锁处理时仍与效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定函数：自己场上是否存在「元素英雄 地球侠」。
function c66367984.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「元素英雄 地球侠」（卡号：74711057）。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,74711057)
end
-- 过滤条件：手卡、墓地或除外状态的，可以无视召唤条件特殊召唤的「元素英雄」怪兽。
function c66367984.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的靶向与发动准备函数：检查怪兽区域空位及是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c66367984.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段首先检查自己的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡、墓地、除外状态中是否存在至少1只满足特殊召唤条件的「元素英雄」怪兽。
		and Duel.IsExistingMatchingCard(c66367984.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从手卡、墓地、除外状态中特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的效果处理函数：从手卡·墓地·除外怪兽中选1只「元素英雄」怪兽无视召唤条件特殊召唤。
function c66367984.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己手卡、墓地、除外状态中满足特殊召唤条件且不受「王家长眠之谷」影响的「元素英雄」怪兽。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c66367984.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or #g==0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	if #sg==0 then return end
	-- 将选中的怪兽以表侧表示无视召唤条件特殊召唤到自己场上。
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
end
