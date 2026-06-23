--水の精霊 アクエリア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只水属性怪兽除外的场合可以特殊召唤。
-- ①：对方准备阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。这个回合，那只怪兽不能把表示形式变更。
function c40916023.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只水属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c40916023.spcon)
	e1:SetTarget(c40916023.sptg)
	e1:SetOperation(c40916023.spop)
	c:RegisterEffect(e1)
	-- 对方准备阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。这个回合，那只怪兽不能把表示形式变更。
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
-- 过滤函数，用于判断墓地是否存在水属性且可除外的怪兽。
function c40916023.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤的条件：场上存在空位且自己墓地存在水属性怪兽。
function c40916023.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否存在空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在至少1只水属性怪兽。
		and Duel.IsExistingMatchingCard(c40916023.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 选择并设置要除外的水属性怪兽。
function c40916023.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的水属性怪兽组。
	local g=Duel.GetMatchingGroup(c40916023.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时将选定的怪兽除外。
function c40916023.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以特殊召唤理由除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 效果发动条件：当前回合不是自己回合。
function c40916023.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，用于判断对方场上的怪兽是否可以改变表示形式。
function c40916023.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 设置效果目标：选择对方场上一只可改变表示形式的怪兽。
function c40916023.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40916023.posfilter(chkc) end
	-- 检查是否存在满足条件的对方怪兽。
	if chk==0 then return Duel.IsExistingTarget(c40916023.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上一只可改变表示形式的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c40916023.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将要改变目标怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行效果：改变目标怪兽的表示形式并使其本回合不能再次改变表示形式。
function c40916023.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() then
		-- 将目标怪兽改变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
		-- 为对象怪兽添加效果，使其本回合不能改变表示形式。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,1)
		tc:RegisterEffect(e1)
	end
end
