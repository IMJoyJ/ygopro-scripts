--炎神－不知火
-- 效果：
-- 不死族调整＋调整以外的不死族怪兽1只以上
-- 自己对「炎神-不知火」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己墓地的卡以及除外的自己的卡之中选不死族同调怪兽任意数量回到额外卡组。那之后，可以选回去数量的对方场上的卡破坏。
-- ②：自己场上的不死族怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地1只「不知火」怪兽除外。
function c59843383.initial_effect(c)
	c:SetSPSummonOnce(59843383)
	-- 为「炎神-不知火」设定同调召唤条件：不死族调整 + 调整以外的不死族怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),aux.NonTuner(Card.IsRace,RACE_ZOMBIE),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己墓地的卡以及除外的自己的卡之中选不死族同调怪兽任意数量回到额外卡组。那之后，可以选回去数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59843383,0))  --"回收不死族同调怪兽"
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c59843383.tdtg)
	e1:SetOperation(c59843383.tdop)
	c:RegisterEffect(e1)
	-- ②：自己场上的不死族怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地1只「不知火」怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c59843383.reptg)
	e2:SetValue(c59843383.repval)
	c:RegisterEffect(e2)
end
-- 筛选可作为回收对象的不死族同调怪兽：位于自己墓地或表侧表示的除外区，且是不死族同调怪兽并可以返回额外卡组。
function c59843383.tdfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 效果发动条件的判定与操作信息设置：检查自己墓地或除外区是否存在至少1只符合条件的不死族同调怪兽，并设置本次效果涉及返回额外卡组。
function c59843383.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己墓地或除外区是否存在至少1只符合条件的不死族同调怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c59843383.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置效果操作信息：预计会从自己墓地或除外区将不死族同调怪兽返回额外卡组，数量设为1（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：从自己墓地或除外区选择任意数量的不死族同调怪兽返回额外卡组；之后若实际返回数量大于0且对方场上有足够卡片，则询问是否选择对方场上相同数量的卡破坏。
function c59843383.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地或除外区中所有满足条件的不死族同调怪兽，组成候选集合g。
	local g=Duel.GetMatchingGroup(c59843383.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()==0 then return end
	-- 向玩家显示“请选择要返回卡组的卡”的提示，以便选择要回额外卡组的同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,1,g:GetCount(),nil)
	-- 将选中的同调怪兽返回卡组（因为是额外卡组的怪兽，实际回到额外卡组），并洗切卡组。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 统计刚才实际返回额外卡组的卡数量，作为后续破坏数量的依据。
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	-- 获取对方场上的所有卡片，作为可被选择破坏的候选对象。
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 判断是否满足破坏条件：实际回额外卡组数量大于0，对方场上卡片数不少于该数量，且玩家选择“是”后才执行破坏。
	if ct>0 and dg:GetCount()>=ct and Duel.SelectYesNo(tp,aux.Stringid(59843383,1)) then  --"是否选对方场上的卡破坏？"
		-- 中断当前效果链，使后续的破坏处理与返回额外卡组的处理视为不同时处理，避免误触发“时”类时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要破坏的卡”的提示，以便选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg2=dg:Select(tp,ct,ct,nil)
		-- 将选中的对方场上的卡片破坏，破坏原因为效果。
		Duel.Destroy(sg2,REASON_EFFECT)
	end
end
-- 定义代替破坏的适用条件：要被破坏的己方怪兽必须是表侧表示的不死族怪兽，且是战斗或效果破坏，并且不是已经被代替破坏处理的对象。
function c59843383.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_ZOMBIE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 筛选自己墓地中可除外的「不知火」怪兽：属于「不知火」字段（0xd9）、是怪兽且可以除外。
function c59843383.rmfilter(c)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 代替破坏效果的发动条件判定：存在满足条件的己方不死族怪兽将被战斗/效果破坏，且自己墓地存在可除外的「不知火」怪兽。
function c59843383.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c59843383.repfilter,1,nil,tp)
		-- 同时检查自己墓地是否存在至少1只符合条件的「不知火」怪兽，作为发动代替破坏效果的必要条件。
		and Duel.IsExistingMatchingCard(c59843383.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 让玩家选择是否发动这个代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 向玩家显示“请选择要除外的卡”的提示，以便选择要除外的「不知火」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择1只符合条件的「不知火」怪兽作为代替破坏的除外对象。
		local g=Duel.SelectMatchingCard(tp,c59843383.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的「不知火」怪兽表侧除外，作为代替破坏的替代代价。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	end
	return false
end
-- 定义代替破坏判定函数：返回指定怪兽是否满足代替破坏条件，以决定是否适用除外「不知火」怪兽代替破坏。
function c59843383.repval(e,c)
	return c59843383.repfilter(c,e:GetHandlerPlayer())
end
