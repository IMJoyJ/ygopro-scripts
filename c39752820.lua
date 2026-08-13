--星鍵士リイヴ
-- 效果：
-- 怪兽2只
-- 这张卡在自己墓地有「星遗物」卡存在的场合才能连接召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组选1张「星遗物」魔法·陷阱卡在自己场上盖放。这个回合，自己墓地没有「星遗物」怪兽存在的场合，那张卡不能发动。
-- ②：连接召唤的这张卡作为连接素材送去墓地的场合才能发动。选场上1张卡回到持有者卡组。
function c39752820.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要且仅需要2只怪兽作为连接素材，对应“怪兽2只”。
	aux.AddLinkProcedure(c,nil,2,2)
	-- 这张卡在自己墓地有「星遗物」卡存在的场合才能连接召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(c39752820.spcost)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从卡组选1张「星遗物」魔法·陷阱卡在自己场上盖放。这个回合，自己墓地没有「星遗物」怪兽存在的场合，那张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39752820,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,39752820)
	e1:SetTarget(c39752820.sttg)
	e1:SetOperation(c39752820.stop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡作为连接素材送去墓地的场合才能发动。选场上1张卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39752820,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,39752821)
	e2:SetCondition(c39752820.tdcon)
	e2:SetTarget(c39752820.tdtg)
	e2:SetOperation(c39752820.tdop)
	c:RegisterEffect(e2)
end
-- 特殊召唤代价判定：若不是连接召唤则放行；若是连接召唤，则要求自己墓地存在「星遗物」卡，作为连接召唤的追加条件。
function c39752820.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	-- 检查自己墓地是否存在至少1张「星遗物」卡，用于满足连接召唤条件。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0xfe)
end
-- 过滤条件：卡名含有「星遗物」、可以盖放且为魔法·陷阱卡的卡。
function c39752820.stfilter(c)
	return c:IsSetCard(0xfe) and c:IsSSetable() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动条件判定：卡组中存在至少1张符合条件的「星遗物」魔法·陷阱卡。
function c39752820.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认卡组有可盖放的「星遗物」魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39752820.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：从卡组选1张「星遗物」魔法·陷阱卡盖放到自己场上；若成功盖放，则给那张卡附加这个回合在墓地无「星遗物」怪兽时不能发动的限制。
function c39752820.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组选择1张满足stfilter条件的「星遗物」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c39752820.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功选到卡并将其盖放到自己场上，则继续给该卡设置不能发动的限制效果。
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个回合，自己墓地没有「星遗物」怪兽存在的场合，那张卡不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetCondition(c39752820.aclimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：是「星遗物」怪兽，用于判断墓地是否存在「星遗物」怪兽。
function c39752820.actfilter(c)
	return c:IsSetCard(0xfe) and c:IsType(TYPE_MONSTER)
end
-- 限制条件：当该盖放的卡不处于效果启用状态，且自己墓地没有「星遗物」怪兽时，该卡不能发动效果。
function c39752820.aclimit(e)
	-- 判断两个条件：该卡未处于效果启用状态，且自己墓地不存在「星遗物」怪兽。
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) and not Duel.IsExistingMatchingCard(c39752820.actfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- ②效果发动条件：这张卡是以连接召唤方式出场，并且作为连接素材被送去墓地（REASON_LINK），且当前在墓地。
function c39752820.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and r==REASON_LINK and c:IsLocation(LOCATION_GRAVE)
end
-- ②效果发动检查：场上存在可送回卡组的卡，并设置操作信息为从场上选1张卡送回持有者卡组。
function c39752820.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上存在至少1张可以被送回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上所有能被送回卡组的卡，作为操作信息的目标集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置本次效果的操作信息：将1张卡送回持有者卡组，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：从双方场上选择1张卡，将其送回持有者卡组并洗牌。
function c39752820.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从双方场上选择1张能够回卡组的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡播放选择动画并记录其被选为对象。
		Duel.HintSelection(g)
		-- 将选中的卡送回其持有者卡组并洗切，处理原因为效果处理。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
