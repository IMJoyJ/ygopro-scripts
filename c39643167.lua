--ウサミミ導師
-- 效果：
-- ①：「兔耳导师」以外的场上的怪兽的效果发动时才能发动（同一连锁上最多1次）。给那只怪兽放置1个兔耳指示物。有兔耳指示物放置的怪兽不会被战斗破坏。
-- ②：1回合1次，以有兔耳指示物放置的1只怪兽为对象才能发动。那只怪兽和这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 创建两个诱发即时效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：「兔耳导师」以外的场上的怪兽的效果发动时才能发动（同一连锁上最多1次）。给那只怪兽放置1个兔耳指示物。有兔耳指示物放置的怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以有兔耳指示物放置的1只怪兽为对象才能发动。那只怪兽和这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"怪兽除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 判断发动效果的怪兽是否在场上且与效果相关，且为怪兽类型且不是兔耳导师本身
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER) and not rc:IsCode(id)
end
-- 检查是否可以给目标怪兽放置指示物且该卡未在本连锁使用过①效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return re:GetHandler():IsCanAddCounter(0x1065,1)
		and c:GetFlagEffect(id)==0 end
	-- 向对方提示发动了①效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 设置操作信息为放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1065)
end
-- 将指示物放置到目标怪兽上，并给该怪兽附加不会被战斗破坏的效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsFaceup() and rc:IsRelateToEffect(re) and rc:AddCounter(0x1065,1) then
		-- 有兔耳指示物放置的怪兽不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetCondition(s.indes)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		rc:RegisterEffect(e1)
	end
end
-- 判断怪兽是否拥有兔耳指示物
function s.indes(e)
	return e:GetHandler():GetCounter(0x1065)>0
end
-- 筛选拥有兔耳指示物且可除外的怪兽
function s.filter(c)
	return c:GetCounter(0x1065)>0 and c:IsAbleToRemove()
end
-- 设置②效果的目标选择条件，需选择拥有兔耳指示物的怪兽
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc~=c end
	if chk==0 then return c:IsAbleToRemove()
		-- 判断是否能选择目标怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向对方提示发动了②效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置操作信息为除外目标怪兽和自己
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g+c,2,0,0)
end
-- 执行②效果，将目标怪兽和自己除外，并设置返回场上的效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	-- 将目标怪兽和自己除外
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		-- 根据当前阶段决定返回场上的回合数
		local ct=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
		-- 获取被除外的卡片组
		local og=Duel.GetOperatedGroup()
		-- 遍历被除外的卡片
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,ct,fid)
		end
		og:KeepAlive()
		-- 设置返回场上的持续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		-- 设置返回场上的触发条件为下个准备阶段
		e1:SetLabel(fid,Duel.GetTurnCount()+1)
		e1:SetLabelObject(og)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
		-- 注册返回场上的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 筛选拥有特定标识的卡片
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 判断是否到达返回场上的条件
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	-- 判断当前回合数是否达到返回条件
	if Duel.GetTurnCount()<ct then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil,fid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行返回场上的操作
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil,fid)
	g:DeleteGroup()
	-- 将符合条件的卡片返回场上
	for tc in aux.Next(sg) do Duel.ReturnToField(tc) end
end
