--メタファイズ・エグゼキューター
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示的卡之中把「玄化」卡5种类各1张除外的场合才能特殊召唤。
-- ①：场上的这张卡不会被效果破坏，不能用效果除外。
-- ②：对方场上的卡数量比自己场上的卡多的场合，1回合1次，以除外的1只自己的「玄化」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
function c45148985.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示的卡之中把「玄化」卡5种类各1张除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：从自己墓地以及自己场上的表侧表示的卡之中把「玄化」卡5种类各1张除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c45148985.sprcon)
	e2:SetTarget(c45148985.sprtg)
	e2:SetOperation(c45148985.sprop)
	c:RegisterEffect(e2)
	-- 效果原文：场上的这张卡不会被效果破坏，不能用效果除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 效果原文：场上的这张卡不会被效果破坏，不能用效果除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c45148985.rmlimit)
	c:RegisterEffect(e4)
	-- 效果原文：对方场上的卡数量比自己场上的卡多的场合，1回合1次，以除外的1只自己的「玄化」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
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
-- 检索满足条件的「玄化」卡（在墓地或场上表侧表示），用于特殊召唤的除外条件检查。
function c45148985.sprfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 检查是否满足特殊召唤条件：从自己墓地及场上表侧表示的卡中选择5种不同种类的「玄化」卡各1张除外。
function c45148985.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的「玄化」卡组（在墓地或场上表侧表示）。
	local g=Duel.GetMatchingGroup(c45148985.sprfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 设置额外检查条件为卡名不同（dncheck）。
	aux.GCheckAdditional=aux.dncheck
	-- 检查是否能选出5张不同种类的卡（满足卡名各不相同且数量为5）。
	local res=g:CheckSubGroup(aux.mzctcheck,5,5,tp)
	-- 清除额外检查条件。
	aux.GCheckAdditional=nil
	return res
end
-- 选择满足条件的5张不同种类的「玄化」卡并设置为本次特殊召唤的除外卡组。
function c45148985.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的「玄化」卡组（在墓地或场上表侧表示）。
	local g=Duel.GetMatchingGroup(c45148985.sprfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置额外检查条件为卡名不同（dncheck）。
	aux.GCheckAdditional=aux.dncheck
	-- 从满足条件的卡中选择5张不同种类的卡作为本次特殊召唤的除外卡组。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,5,5,tp)
	-- 清除额外检查条件。
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选中的卡组以特殊召唤原因除外。
function c45148985.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡组以特殊召唤原因除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 限制该卡不能被效果除外。
function c45148985.rmlimit(e,c,tp,r)
	return c==e:GetHandler() and r==REASON_EFFECT
end
-- 判断是否满足发动条件：对方场上的卡数量比自己场上的卡多。
function c45148985.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：对方场上的卡数量比自己场上的卡多。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 检索满足条件的「玄化」怪兽（在除外区），用于特殊召唤。
function c45148985.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择除外区的1只「玄化」怪兽作为特殊召唤对象。
function c45148985.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c45148985.spfilter(chkc,e,tp) end
	-- 判断是否满足发动条件：自己场上存在空位且除外区存在符合条件的「玄化」怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：自己场上存在空位且除外区存在符合条件的「玄化」怪兽。
		and Duel.IsExistingTarget(c45148985.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区的1只符合条件的「玄化」怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c45148985.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置本次特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，并注册结束阶段除外效果。
function c45148985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次特殊召唤的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(45148985,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 效果原文：对方场上的卡数量比自己场上的卡多的场合，1回合1次，以除外的1只自己的「玄化」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置效果标签为下个回合的回合数。
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetCondition(c45148985.rmcon)
		e2:SetOperation(c45148985.rmop)
		-- 将效果注册到玩家环境。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否满足结束阶段除外条件：当前回合数等于设定的回合数且目标怪兽仍存在。
function c45148985.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(45148985)~=0 then
		-- 判断是否满足结束阶段除外条件：当前回合数等于设定的回合数。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 将目标怪兽以效果原因除外。
function c45148985.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以效果原因除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
