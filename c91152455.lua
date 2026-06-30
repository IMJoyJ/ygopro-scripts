--メタル化・鋼炎装甲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把有「金属化·强化反射装甲」的卡名记述的自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽无视召唤条件从卡组特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动（魔陷卡的发动）效果
function s.initial_effect(c)
	-- 记录该卡片文本中记述了卡名「金属化·强化反射装甲」
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
-- 过滤自己场上记述有「金属化·强化反射装甲」的表侧表示怪兽
function s.cfilter(c,e,tp)
	-- 检查怪兽是否记述有「金属化·强化反射装甲」且为表侧表示，并确保其解放后可以腾出足够的怪兽区域空位
	return aux.IsCodeListed(c,89812483) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 卡片发动的代价处理，解放自己场上1只记述有「金属化·强化反射装甲」的表侧表示怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 在发动代价检测阶段检查场上是否存在至少1只符合条件的怪兽可供解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp) end
	-- 选择自己场上1只符合条件的表侧表示怪兽作为解放的对象
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp)
	-- 将选择的怪兽解放以支付发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤卡组中记述有「金属化·强化反射装甲」的不能通常召唤且可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	-- 检查怪兽是否记述有「金属化·强化反射装甲」且不能通常召唤
	return aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER) and not c:IsSummonableCard()
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 卡片发动的目标检测，检查是否存在可特殊召唤的怪兽，并注册特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		-- 检查自己场上是否有空余的怪兽区域（或解放代价能腾出空位），并且卡组中是否存在可以特殊召唤的怪兽
		return (res or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置效果处理的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 卡片发动的效果处理，无视召唤条件特殊召唤卡组中符合条件的怪兽，并可选择将其作为装备卡给其装备
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有可用的怪兽区域则无法处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 检查是否成功将选择的怪兽以无视召唤条件的形式特殊召唤，并且确认之前成功支付了发动的解放代价
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)~=0 and e:GetLabel()==100
		-- 检查此卡是否仍在场上、是否仍与效果相关，并询问玩家是否将其作为装备卡装备给那只怪兽
		and c:IsOnField() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否装备？"
		-- 中断当前效果，使得特殊召唤与装备的处理视为不同时进行
		Duel.BreakEffect()
		c:CancelToGrave(true)
		-- 检查是否成功将此卡作为装备卡装备给特殊召唤的怪兽
		if Duel.Equip(tp,c,tc) then
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
-- 定义装备限制：只有此卡的拥有者怪兽才可以装备此卡
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代替破坏效果的发动目标，检查装备怪兽是否因战斗或效果将被破坏，以及装备卡是否可送去墓地，并询问玩家是否适用代替效果
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) end
	-- 让玩家选择是否适用此卡代替装备怪兽被破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的效果处理，将此装备卡送去墓地代替装备怪兽的破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此装备卡作为代替破坏的效果处理送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
