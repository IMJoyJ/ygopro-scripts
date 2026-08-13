--水の精霊 アクエリア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只水属性怪兽除外的场合可以特殊召唤。
-- ①：对方准备阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。这个回合，那只怪兽不能把表示形式变更。
function c40916023.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只水属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c40916023.spcon)
	e1:SetTarget(c40916023.sptg)
	e1:SetOperation(c40916023.spop)
	c:RegisterEffect(e1)
	-- 对方准备阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40916023,0))  --"改变表示形式"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c40916023.poscon)
	e2:SetTarget(c40916023.postg)
	e2:SetOperation(c40916023.posop)
	c:RegisterEffect(e2)
end
-- 筛选可除外的cost：满足水属性且可以作为除外代价的怪兽。
function c40916023.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续的发动条件：自己主要怪兽区有空位，且墓地存在至少1只水属性可除外的怪兽作为代价；c为空时表示规则上的可发动判定，直接通过。
function c40916023.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足spfilter（水属性且可除外）的卡作为特殊召唤的除外代价。
		and Duel.IsExistingMatchingCard(c40916023.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤手续的选择：从墓地中选择1只水属性怪兽作为除外的cost，用SetLabelObject暂存；未选择到则返回false取消特殊召唤。
function c40916023.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter（水属性且可除外）的怪兽集合。
	local g=Duel.GetMatchingGroup(c40916023.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 显示选择提示文本“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作：取出暂存的卡片并将其除外，完成特殊召唤的代价处理。
function c40916023.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定怪兽以表侧表示除外，除外原因记为特殊召唤手续（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动条件：当前回合玩家是对方，即仅在对方准备阶段满足。
function c40916023.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己（即处于对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 取对象过滤器：选择表侧表示且当前可以变更表示形式的怪兽。
function c40916023.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- ①效果的发动目标处理：选择对方场上1只表侧表示且可变更表示形式的怪兽为对象，并设置操作信息为表示形式变更。
function c40916023.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40916023.posfilter(chkc) end
	-- 在发动时确认是否存在至少1只合法对象（对方场上的表侧表示、可变更表示形式的怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c40916023.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示文本“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从对方场上选择1只满足posfilter的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c40916023.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息为改变表示形式（CATEGORY_POSITION），目标为已选对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ①效果处理：将对象怪兽的表示形式变更；若对象仍然合法，则给它附加这个回合不能变更表示形式的效果。
function c40916023.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() then
		-- 变更对象表示形式：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
		-- 这个回合，那只怪兽不能把表示形式变更。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,1)
		tc:RegisterEffect(e1)
	end
end
