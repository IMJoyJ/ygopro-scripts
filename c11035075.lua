--死地誤算守護
-- 效果：
-- ①：自己或对方的墓地1只1星或1阶的怪兽在自己场上特殊召唤，把这张卡装备。
-- ②：自己·对方的结束阶段发动。装备怪兽的等级·阶级上升1。
-- ③：装备怪兽的等级·阶级的以下效果适用。
-- ●3以上：那只怪兽的攻击力上升那个原本攻击力数值。
-- ●5以上：那只怪兽不受对方发动的效果影响。
-- ④：自己准备阶段，装备怪兽的等级·阶级是7以上的场合发动。场上的卡全部送去墓地。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册所有效果
function s.initial_effect(c)
	-- ①：自己或对方的墓地1只1星或1阶的怪兽在自己场上特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段发动。装备怪兽的等级·阶级上升1。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：装备怪兽的等级·阶级的以下效果适用。●3以上：那只怪兽的攻击力上升那个原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.lvcon(3))
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	-- ③：装备怪兽的等级·阶级的以下效果适用。●5以上：那只怪兽不受对方发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(s.lvcon(5))
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	-- ④：自己准备阶段，装备怪兽的等级·阶级是7以上的场合发动。场上的卡全部送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.tgcon2)
	e5:SetTarget(s.tgtg2)
	e5:SetOperation(s.tgop2)
	c:RegisterEffect(e5)
end
-- 成本函数，设置卡牌在发动时保持在场上的效果
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置卡牌在发动时保持在场上的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 设置连锁被无效时的处理效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册连锁被无效时的处理效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选墓地1星或1阶怪兽的过滤函数
function s.spfilter(c,e,tp)
	return (c:IsLevel(1) or c:IsRank(1)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
-- 目标函数，检查是否满足发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 装备限制函数，确保只能装备给特定怪兽
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 发动函数，执行特殊召唤并装备
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 执行特殊召唤
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 将卡装备给特殊召唤的怪兽
			Duel.Equip(tp,c,tc)
			-- 设置装备限制，防止被其他卡装备
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			c:RegisterEffect(e1)
		end
	end
	if c:IsOnField() and not c:GetEquipTarget() then
		c:CancelToGrave(false)
	end
end
-- 等级提升效果的目标函数
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():GetEquipTarget() end
end
-- 等级提升效果的发动函数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc:IsFaceup() then
		-- 根据怪兽等级或阶级设置提升等级或阶级的效果
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		if tc:IsLevelAbove(1) then
			e1:SetCode(EFFECT_UPDATE_LEVEL)
		else
			e1:SetCode(EFFECT_UPDATE_RANK)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 等级或阶级条件函数，用于判断是否满足效果触发条件
function s.lvcon(lv)
	return function(e)
				local tc=e:GetHandler():GetEquipTarget()
				return tc:IsLevelAbove(lv) or tc:IsRankAbove(lv)
			end
end
-- 攻击力提升值函数，返回怪兽原本攻击力
function s.atkval(e,c)
	return c:GetBaseAttack()
end
-- 效果免疫过滤函数，判断是否免疫对方发动的效果
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActivated()
end
-- 墓地送卡条件函数，判断是否满足送墓条件
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
		and (tc:IsLevelAbove(7) or tc:IsRankAbove(7))
end
-- 墓地送卡的目标函数
function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有可送去墓地的卡
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，指定要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,dg,dg:GetCount(),0,0)
end
-- 墓地送卡的发动函数
function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可送去墓地的卡
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将卡送去墓地
	Duel.SendtoGrave(dg,REASON_EFFECT)
end
