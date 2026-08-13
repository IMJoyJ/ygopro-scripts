--超竜災禍
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己的手卡·墓地·除外状态的1只「征龙」怪兽特殊召唤。那之后，可以只用自己场上的「征龙」怪兽为素材进行1只「征龙」超量怪兽的超量召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己的除外状态的「征龙」怪兽任意数量为对象才能发动（相同属性最多1只）。那些怪兽回到墓地。
local s,id,o=GetID()
-- 注册卡片的两个效果：①是在手卡发动的魔法效果，进行征龙特殊召唤并可追加征龙超量召唤；②是墓地发动的起动效果，除外自身并将除外状态的征龙返回墓地。
function s.initial_effect(c)
	-- ①：自己的手卡·墓地·除外状态的1只「征龙」怪兽特殊召唤。那之后，可以只用自己场上的「征龙」怪兽为素材进行1只「征龙」超量怪兽的超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己的除外状态的「征龙」怪兽任意数量为对象才能发动（相同属性最多1只）。那些怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 把墓地的这张卡除外作为发动代价（即从墓地除外自身）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 特召筛选：判定为可被当前效果特殊召唤的「征龙」怪兽（允许从手卡·墓地·除外状态选择）。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查：chk==0时，确认自己的主要怪兽区有空位，并且手卡·墓地·除外区存在至少1只可特殊召唤的「征龙」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：自己的主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查（后半）：是否存在至少1只满足s.spfilter的「征龙」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 把本次操作信息登记为特殊召唤1只怪兽，候选区域为手卡·墓地·除外区，供后续发动时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 超量素材筛选：自己场上表侧表示的「征龙」怪兽，且不能是衍生物。
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c4) and not c:IsType(TYPE_TOKEN)
end
-- 超量怪兽筛选：额外卡组中的「征龙」超量怪兽，可以用当前素材组mg进行超量召唤。
function s.xyzfilter(c,mg)
	return c:IsSetCard(0x1c4) and c:IsXyzSummonable(mg)
end
-- ①效果处理：先选择并特殊召唤1只「征龙」怪兽，成功后若额外卡组有可用素材进行超量召唤的「征龙」怪兽，则询问玩家是否进行超量召唤，同意后从候选中选择1只并以自己场上的「征龙」怪兽为素材进行超量召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，否则直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地·除外区选择1张满足s.spfilter的「征龙」怪兽；使用NecroValleyFilter排除受王家长眠之谷效果影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 若选择到了卡且特殊召唤成功，则继续后续的超量召唤选择。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 刷新场上状态，确保超量召唤的判断基于最新的怪兽区域信息。
		Duel.AdjustAll()
		-- 获取自己场上可作为超量素材的「征龙」怪兽（表侧表示且非衍生物）。
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断额外卡组是否存在能用当前素材组进行超量召唤的「征龙」超量怪兽。
		if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
			-- 如果有，则询问玩家是否进行超量召唤；玩家选择是才继续。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行超量召唤？"
			-- 获取所有可选的「征龙」超量怪兽候选集合。
			local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
			-- 弹出选择提示，让玩家选择要超量召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			-- 中断当前效果，使超量召唤作为独立处理，避免影响时点。
			Duel.BreakEffect()
			-- 以自己场上的1~6只「征龙」怪兽为素材，对选中的超量怪兽进行超量召唤。
			Duel.XyzSummon(tp,xyz,mg,1,6)
		end
	end
end
-- ②效果对象筛选：除外区表侧表示的「征龙」怪兽，且能够成为效果对象。
function s.tgfilter(c,e)
	return c:IsSetCard(0x1c4) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end
-- ②效果的目标选择：从除外区选择任意数量（1~7只）符合条件的「征龙」怪兽，要求相同属性最多1只，将选中的卡设置为效果对象并登记送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取除外区所有符合条件的「征龙」怪兽作为候选集合。
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #tg>0 end
	-- 弹出选择提示，让玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 设置额外检查条件：所选卡的属性必须互不相同（相同属性最多1只）。
	aux.GCheckAdditional=aux.dabcheck
	-- 从候选集合中选择1~7只卡（实际受属性互异限制）。
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,7)
	-- 清除额外检查条件，避免影响后续其他选择。
	aux.GCheckAdditional=nil
	-- 将选中的卡组设为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 登记操作信息：将这些卡送去墓地（数量为选中的卡数）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②效果处理：取得仍然与效果关联的对象卡，并将其送回墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象卡，并过滤掉已与效果失去联系的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 把对象卡送往墓地，原因包含效果和返回（REASON_RETURN表示回到墓地）。
		Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
	end
end
