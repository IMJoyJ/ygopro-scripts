--蕾禍ノ曝藤
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡发动后变成通常怪兽（植物族·暗·4星·攻1600/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「蕾祸」连接怪兽存在的场合，可以再从对方墓地把最多2张卡除外。
-- ②：自己·对方的结束阶段，这张卡在墓地存在的场合才能发动。自己的墓地·除外状态的2只昆虫族·植物族·爬虫类族怪兽回到卡组，这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册此卡的效果①（发动后特殊召唤为陷阱怪兽）与效果②（结束阶段从墓地自身盖放）
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
	-- ②：自己·对方的结束阶段，这张卡在墓地存在的场合才能发动。自己的墓地·除外状态的2只昆虫族·植物族·爬虫类族怪兽回到卡组，这张卡在自己场上盖放。
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
-- 特殊召唤效果的发动条件检测
function s.tsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 判断己方主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否能将指定属性与种族的陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) end
	-- 设置效果处理的分类为将此卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤自己场上表侧表示的「蕾祸」连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ab) and c:IsType(TYPE_LINK)
end
-- 特殊召唤自身为陷阱怪兽的效果处理，若己方场上有「蕾祸」连接怪兽，可选择是否除外对方墓地的卡
function s.tspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若玩家无法将此陷阱怪兽特殊召唤，则效果不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 若此卡成功特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 并且检查己方场上是否存在「蕾祸」连接怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查对方墓地是否存在可以除外的卡片
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil)
		-- 询问玩家是否要选择除外对方墓地的卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外对方墓地的卡？"
		-- 中断当前效果处理，使后续的除外步骤与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从对方墓地中选择1至2张可以除外的卡片
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,2,nil)
		if g:GetCount()>0 then
			-- 将选中的对方墓地卡片除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 判断当前是否在结束阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前为结束阶段则条件满足
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤自己墓地或除外状态的昆虫族、植物族、爬虫类族怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeck()
end
-- 盖放效果的发动条件检测与操作信息设置
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则判断此卡是否可盖放，且己方墓地或除外状态是否存在至少2只上述三种族的怪兽
	if chk==0 then return e:GetHandler():IsSSetable() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	-- 设置效果处理的分类为让此卡离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	-- 设置效果处理的分类为将2张墓地或除外的卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 盖放效果处理，让选中的2只墓地或除外怪兽回到卡组，并将此卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方墓地及除外状态中所有满足条件的怪兽
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if rg:GetCount()<2 then return end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=rg:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		-- 手动为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(sg)
		local c=e:GetHandler()
		-- 如果成功将选中的卡片送回卡组且其中有卡进入卡组或额外卡组
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			-- 且此卡依然与效果相关并且不受「王家长眠之谷」影响时
			and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
			-- 将此卡在己方魔陷区盖放
			Duel.SSet(tp,c)
		end
	end
end
