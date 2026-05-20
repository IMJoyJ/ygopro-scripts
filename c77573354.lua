--蕾禍ノ曝藤
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡发动后变成通常怪兽（植物族·暗·4星·攻1600/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「蕾祸」连接怪兽存在的场合，可以再从对方墓地把最多2张卡除外。
-- ②：自己·对方的结束阶段，这张卡在墓地存在的场合才能发动。自己的墓地·除外状态的2只昆虫族·植物族·爬虫类族怪兽回到卡组，这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动并特招为陷阱怪兽，可选除外对方墓地卡）和②效果（结束阶段回收墓地/除外怪兽并盖放自身）。
function s.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（植物族·暗·4星·攻1600/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「蕾祸」连接怪兽存在的场合，可以再从对方墓地把最多2张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.tsptg)
	e1:SetOperation(s.tspop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，这张卡在墓地存在的场合才能发动。自己的墓地·除外状态的2只昆虫族·植物族·爬虫类族怪兽回到卡组，这张卡在自己场上盖放。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检测，确认怪兽区域有空位且可以特殊召唤此陷阱怪兽。
function s.tsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为特定属性、种族、攻守和等级的通常怪兽（陷阱怪兽）特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) end
	-- 设置连锁处理中的操作信息，表示此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：自己场上表侧表示的「蕾祸」连接怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ab) and c:IsType(TYPE_LINK)
end
-- ①效果的处理：将自身作为陷阱怪兽特殊召唤，若自己场上有「蕾祸」连接怪兽，可选择将对方墓地最多2张卡除外。
function s.tspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否仍能将此卡作为陷阱怪兽特殊召唤，若不能则直接结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将此卡以表侧表示特殊召唤，并判断是否特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在「蕾祸」连接怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方墓地是否存在可以除外的卡（受王家之谷影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil)
		-- 询问玩家是否选择发动追加效果，从对方墓地除外卡片。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外对方墓地的卡？"
		-- 中断当前效果处理，使后续的除外处理与特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从对方墓地选择1到2张可以除外的卡（受王家之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,2,nil)
		if g:GetCount()>0 then
			-- 将选中的卡片以表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：当前处于自己或对方的结束阶段。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为结束阶段。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤条件：自己墓地或除外状态的昆虫族、植物族、爬虫类族怪兽，且能回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeck()
end
-- ②效果的发动准备与合法性检测，确认自身可盖放且有2只满足条件的怪兽可回收。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否可以盖放到魔法与陷阱区域，且自己墓地或除外状态是否存在至少2只满足条件的怪兽。
	if chk==0 then return e:GetHandler():IsSSetable() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	-- 设置连锁处理中的操作信息，表示此效果包含此卡离开墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	-- 设置连锁处理中的操作信息，表示此效果包含将自己墓地或除外状态的2张卡送回卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理：将自己墓地或除外状态的2只昆虫族/植物族/爬虫类族怪兽回到卡组，并将此卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地及除外状态中所有满足回收条件的怪兽（受王家之谷影响）。
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if rg:GetCount()<2 then return end
	-- 提示玩家选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=rg:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		-- 手动为选中的卡片显示被选为效果处理对象的动画效果。
		Duel.HintSelection(sg)
		local c=e:GetHandler()
		-- 将选中的怪兽送回卡组并洗牌，并确认是否有至少1张卡成功回到了主卡组或额外卡组。
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			-- 确认此卡仍与效果相关联，且在墓地中不受王家之谷影响。
			and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
			-- 将此卡在自己场上盖放。
			Duel.SSet(tp,c)
		end
	end
end
