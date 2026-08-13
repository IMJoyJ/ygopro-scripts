--蕾禍ノ曝藤
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡发动后变成通常怪兽（植物族·暗·4星·攻1600/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「蕾祸」连接怪兽存在的场合，可以再从对方墓地把最多2张卡除外。
-- ②：自己·对方的结束阶段，这张卡在墓地存在的场合才能发动。自己的墓地·除外状态的2只昆虫族·植物族·爬虫类族怪兽回到卡组，这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册这张卡的两个效果：e1为①的发动效果，在自由时点特殊召唤自身并可追加除外；e2为②的墓地诱发即时效果，1回合1次，在结束阶段把墓地·除外的怪兽回卡组并盖放这张卡。
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
	-- ②：自己·对方的结束阶段，这张卡在墓地存在的场合才能发动。自己的墓地·除外状态的2只昆虫族·植物族·爬虫类族怪兽回到卡组，这张卡在自己场上盖放。（这个卡名的②的效果1回合只能使用1次。）
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
-- ①效果的目标函数：发动检测时要求已支付代价、自己怪兽区域有空位，且玩家可以把这张卡当作植物族·暗·4星·攻1600/守0的通常陷阱怪兽特殊召唤。
function s.tsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检测自己的怪兽区域还有可用空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测玩家是否可以把这张卡以通常陷阱怪兽（植物族·暗·4星·攻1600/守0）特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) end
	-- 设置操作信息：宣告本次连锁确定要特殊召唤1张卡（这张卡自身）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤器：表侧表示的「蕾祸」连接怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ab) and c:IsType(TYPE_LINK)
end
-- ①效果的处理：把这张卡变成通常陷阱怪兽在自己场上表侧特殊召唤；若自己场上有「蕾祸」连接怪兽且对方墓地有可除外的卡，可询问玩家后从对方墓地选最多2张卡除外。
function s.tspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检测是否可以把这张卡以通常陷阱怪兽特殊召唤，不能则中断处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 把这张卡以表侧表示特殊召唤到自己的怪兽区域（无视召唤条件），并确认特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 检测自己场上是否存在表侧表示的「蕾祸」连接怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检测对方墓地是否存在可以除外且不受「王家长眠之谷」影响的卡。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil)
		-- 询问玩家是否除外对方墓地的卡，选择否则跳过追加处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外对方墓地的卡？"
		-- 中断当前效果处理，使之后的除外处理与特殊召唤视为不同时处理。
		Duel.BreakEffect()
		-- 向玩家发送选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从对方墓地选择1～2张可以除外（且不受「王家长眠之谷」影响）的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,2,nil)
		if g:GetCount()>0 then
			-- 把选中的卡以表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件函数：仅在结束阶段可以发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前阶段为结束阶段。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤器：自己墓地或除外状态的表侧昆虫族·植物族·爬虫类族且可以回到卡组的怪兽。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeck()
end
-- ②效果的目标函数：发动检测要求这张卡可以在自己场上盖放，且自己墓地·除外状态有2只以上满足条件的怪兽；并设置离开墓地与回卡组的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：这张卡可以盖放到自己的魔法·陷阱区域，且自己墓地·除外状态存在至少2只昆虫族·植物族·爬虫类族且可回卡组的怪兽。
	if chk==0 then return e:GetHandler():IsSSetable() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	-- 设置操作信息：宣告这张卡将离开墓地（盖放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	-- 设置操作信息：宣告将把自己墓地·除外状态的2张卡回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理：从自己墓地·除外状态选出2只满足条件的怪兽回到卡组（洗牌），成功回到卡组后把这张卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己墓地·除外状态所有满足条件且不受「王家长眠之谷」影响的怪兽。
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if rg:GetCount()<2 then return end
	-- 向玩家发送选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=rg:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		-- 为选中的2张卡显示被选中的动画并记录。
		Duel.HintSelection(sg)
		local c=e:GetHandler()
		-- 把选中的怪兽送去卡组洗切，并确认其中有卡实际回到了卡组或额外卡组。
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			-- 确认这张卡仍与此效果关联且不受「王家长眠之谷」影响。
			and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
			-- 把这张卡在自己场上盖放。
			Duel.SSet(tp,c)
		end
	end
end
