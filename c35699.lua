--SPYRAL－ボルテックス
-- 效果：
-- 这张卡不能通常召唤。把自己墓地3张「秘旋谍」卡除外的场合才能特殊召唤。
-- ①：1回合1次，以自己场上1张「秘旋谍」卡和对方场上最多2张卡为对象才能发动。那些卡破坏。这个效果在对方回合也能发动。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合发动。自己场上的卡全部破坏，从自己的手卡·卡组·墓地选1只「秘旋谍-花公子」特殊召唤。
function c35699.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地3张「秘旋谍」卡除外的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这张卡不能通常召唤。把自己墓地3张「秘旋谍」卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c35699.sprcon)
	e1:SetTarget(c35699.sprtg)
	e1:SetOperation(c35699.sprop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1张「秘旋谍」卡和对方场上最多2张卡为对象才能发动。那些卡破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35699,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c35699.destg)
	e2:SetOperation(c35699.desop)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合发动。自己场上的卡全部破坏，从自己的手卡·卡组·墓地选1只「秘旋谍-花公子」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35699,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c35699.spcon)
	e3:SetTarget(c35699.sptg)
	e3:SetOperation(c35699.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选墓地中的「秘旋谍」卡并满足可以除外的条件。
function c35699.sprfilter(c)
	return c:IsSetCard(0xee) and c:IsAbleToRemoveAsCost()
end
-- 判断特殊召唤条件是否满足：场上是否有空位且自己墓地是否有3张「秘旋谍」卡。
function c35699.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否有3张「秘旋谍」卡。
		and Duel.IsExistingMatchingCard(c35699.sprfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 选择3张墓地中的「秘旋谍」卡进行除外操作。
function c35699.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中的所有「秘旋谍」卡。
	local g=Duel.GetMatchingGroup(c35699.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的除外操作。
function c35699.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡以除外形式移出游戏。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于筛选场上正面表示的「秘旋谍」卡。
function c35699.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xee)
end
-- 设置效果发动时的目标选择条件：自己场上至少1张「秘旋谍」卡和对方场上至少1张卡。
function c35699.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1张「秘旋谍」卡。
	if chk==0 then return Duel.IsExistingTarget(c35699.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少1张卡。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张「秘旋谍」卡作为目标。
	local g1=Duel.SelectTarget(tp,c35699.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上最多2张卡作为目标。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
	g1:Merge(g2)
	-- 设置效果处理时要破坏的卡组。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 执行破坏效果。
function c35699.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组进行破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 判断该卡是否因战斗或效果破坏并进入墓地。
function c35699.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选「秘旋谍-花公子」卡并满足可以特殊召唤的条件。
function c35699.spfilter(c,e,tp)
	return c:IsCode(41091257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的操作信息：破坏自己场上的所有卡并准备特殊召唤「秘旋谍-花公子」。
function c35699.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的所有卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if chk==0 then return true end
	-- 设置效果处理时要破坏的卡组。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置效果处理时要特殊召唤的卡组来源。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行效果处理：破坏自己场上的所有卡并特殊召唤「秘旋谍-花公子」。
function c35699.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有卡。
	local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	-- 判断自己场上的卡是否被破坏成功。
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
		-- 判断自己场上是否有空位。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌、卡组或墓地中选择1只「秘旋谍-花公子」进行特殊召唤。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35699.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选定的卡以特殊召唤形式放置到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
