--メタファイズ・エグゼキューター
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示的卡之中把「玄化」卡5种类各1张除外的场合才能特殊召唤。
-- ①：场上的这张卡不会被效果破坏，不能用效果除外。
-- ②：对方场上的卡数量比自己场上的卡多的场合，1回合1次，以除外的1只自己的「玄化」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
function c45148985.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从自己墓地以及自己场上的表侧表示的卡之中把「玄化」卡5种类各1张除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c45148985.sprcon)
	e2:SetTarget(c45148985.sprtg)
	e2:SetOperation(c45148985.sprop)
	c:RegisterEffect(e2)
	-- 场上的这张卡不会被效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 不能用效果除外
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c45148985.rmlimit)
	c:RegisterEffect(e4)
	-- ②：对方场上的卡数量比自己场上的卡多的场合，1回合1次，以除外的1只自己的「玄化」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(45148985,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c45148985.spcon)
	e5:SetTarget(c45148985.sptg)
	e5:SetOperation(c45148985.spop)
	c:RegisterEffect(e5)
end
-- 筛选可作为特殊召唤代价的「玄化」卡：必须是「玄化」卡、可以除外，且位于墓地或场上表侧表示。
function c45148985.sprfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 特殊召唤手续的条件检查：从自己场上表侧表示和墓地的「玄化」卡中，确认是否存在5张卡名互不相同且除外后自己场上仍有可用怪兽区域的组合。
function c45148985.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上表侧表示及墓地的所有可作为代价除外的「玄化」卡。
	local g=Duel.GetMatchingGroup(c45148985.sprfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 设置额外的分组检查条件：要求选出的卡名互不相同（对应5种类各1张）。
	aux.GCheckAdditional=aux.dncheck
	-- 检查是否存在一组5张「玄化」卡，满足卡名互不相同，且将它们除外后自己场上仍有可用怪兽区域。
	local res=g:CheckSubGroup(aux.mzctcheck,5,5,tp)
	-- 清除临时设置的额外检查条件。
	aux.GCheckAdditional=nil
	return res
end
-- 特殊召唤手续的选牌处理：从候选「玄化」卡中选择5张卡名互不相同且满足格子的卡作为除外代价，保存选择结果。
function c45148985.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上表侧表示及墓地的所有可作为代价除外的「玄化」卡。
	local g=Duel.GetMatchingGroup(c45148985.sprfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置额外的分组检查条件：要求选出的卡名互不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家选择5张「玄化」卡作为除外代价，并保证卡名互不相同且除外后场上仍有空位。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,5,5,tp)
	-- 清除临时设置的额外检查条件。
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续执行：将之前选择的5张「玄化」卡作为祭品除外，完成特殊召唤手续。
function c45148985.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以表侧表示除外选择的「玄化」卡，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判定是否受到“不能用效果除外”的限制：仅当对象为这张卡自身且除外原因为效果时适用。
function c45148985.rmlimit(e,c,tp,r)
	return c==e:GetHandler() and r==REASON_EFFECT
end
-- ②效果的发动条件：对方场上的卡数量多于自己场上的卡。
function c45148985.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方场上与己方场上的卡数，返回对方是否更多。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 筛选特殊召唤对象：除外的自己的表侧表示「玄化」怪兽，且满足特殊召唤条件。
function c45148985.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择处理：确认自己场上有空位，并从除外区选择1只符合条件的「玄化」怪兽作为对象。
function c45148985.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c45148985.spfilter(chkc,e,tp) end
	-- 效果发动时检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在1只满足条件的「玄化」怪兽可以作为对象。
		and Duel.IsExistingTarget(c45148985.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外的自己的「玄化」怪兽中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,c45148985.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置本次效果的操作信息：将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽特殊召唤；成功则给它注册下个回合结束阶段除外的效果。
function c45148985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（那只被选中的「玄化」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联后将其特殊召唤；若召唤成功则继续注册除外效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(45148985,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 记录“下个回合”的回合数标记，用于在正确的结束阶段触发除外。
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetCondition(c45148985.rmcon)
		e2:SetOperation(c45148985.rmop)
		-- 将“下个回合结束阶段除外”的延迟效果注册到场上。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判定除外的时机：被特殊召唤的怪兽仍存在且当前回合数达到记录的回合数时，执行除外。
function c45148985.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(45148985)~=0 then
		-- 返回当前回合数是否等于记录的回合数。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 执行除外操作：将那只怪兽除外。
function c45148985.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将对象怪兽以表侧表示除外，原因是效果。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
