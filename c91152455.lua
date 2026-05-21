--メタル化・鋼炎装甲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把有「金属化·强化反射装甲」的卡名记述的自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽无视召唤条件从卡组特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 将「金属化·强化反射装甲」的卡片密码注册到该卡的关联卡片列表中。
	aux.AddCodeList(c,89812483)
	-- 这个卡名的卡在1回合只能发动1张。①：把有「金属化·强化反射装甲」的卡名记述的自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽无视召唤条件从卡组特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足解放条件的怪兽：记述有「金属化·强化反射装甲」且在场上表侧表示存在，且解放后能腾出怪兽区域。
function s.cfilter(c,e,tp)
	-- 检查卡片是否记述有「金属化·强化反射装甲」、是否表侧表示，以及解放该卡后自己场上是否有可用的怪兽区域。
	return aux.IsCodeListed(c,89812483) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动的代价处理函数：解放1只满足条件的怪兽。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 步骤0：检查自己场上是否存在至少1只满足解放条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp) end
	-- 玩家选择1只满足解放条件的怪兽。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp)
	-- 将选中的怪兽作为发动代价解放。
	Duel.Release(g,REASON_COST)
end
-- 过滤满足特殊召唤条件的怪兽：卡组中记述有「金属化·强化反射装甲」的不能通常召唤的怪兽。
function s.spfilter(c,e,tp)
	-- 检查卡片是否记述有「金属化·强化反射装甲」、是否为怪兽卡，以及是否为不能通常召唤的怪兽。
	return aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER) and not c:IsSummonableCard()
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果发动的目标确认与操作信息设置函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		-- 检查自己场上是否有空余的怪兽区域（或已支付解放代价），且卡组中存在至少1只满足特殊召唤条件的怪兽。
		return (res or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置当前处理的连锁操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（特殊召唤及后续装备）的主函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 向玩家发送提示信息，选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足特殊召唤条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤，并检查特殊召唤是否成功以及是否支付了正确的代价。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)~=0 and e:GetLabel()==100
		-- 检查此卡是否仍在场上、是否与效果相关联，并询问玩家是否选择将其作为装备卡装备给特殊召唤的怪兽。
		and c:IsOnField() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否装备？"
		-- 中断当前效果处理，使后续的装备处理不与特殊召唤视为同时处理。
		Duel.BreakEffect()
		c:CancelToGrave(true)
		-- 尝试将此卡作为装备卡装备给特殊召唤的怪兽，并判断是否装备成功。
		if Duel.Equip(tp,c,tc)~=0 then
			-- 那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			c:RegisterEffect(e1)
			-- ●装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_DESTROY_REPLACE)
			e2:SetTarget(s.destg)
			e2:SetOperation(s.desop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		else
			c:CancelToGrave(false)
		end
	end
end
-- 装备限制函数：此卡只能装备给该效果特殊召唤的怪兽。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代替破坏效果的目标确认函数：检查装备怪兽是否因战斗或效果将被破坏，且此卡是否可以送去墓地。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) end
	-- 询问玩家是否使用此卡的代替破坏效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的操作处理函数：将此卡送去墓地代替怪兽的破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡作为代替破坏送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
