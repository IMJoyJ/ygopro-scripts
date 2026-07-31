--Distrust Paranoia
local s,id,o=GetID()
-- 初始化卡片效果：注册①发动获得同纵列怪兽控制权、②被对方送墓/除外时作为陷阱怪兽特召、③同纵列对方效果免疫
function s.initial_effect(c)
	-- ①：这张卡发动时，可以得到与这张卡相同纵列的对方1只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	-- ②：场上盖放的这张卡因对方的效果送去墓地或除外的场合才能发动。这张卡变成效果怪兽（恶魔族·暗·10星·攻/守4000）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	-- ③：这个效果特殊召唤的这张卡不受与自身相同纵列的对方发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.efcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end
-- 控制权变更过滤条件：对方怪兽区域的怪兽且可变更控制权
function s.cfilter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControlerCanBeChanged() and c:IsControler(1-tp)
end
-- 区域限制过滤条件：同纵列存在可变更控制权的对方怪兽，且控制权变更后怪兽区域有空位
function s.cfilter(c,tp)
	-- 检查同纵列对方怪兽数量是否小于玩家可接收的怪兽区域数量
	return c:IsControlerCanBeChanged() and c:GetColumnGroup():FilterCount(s.cfilter2,nil,tp)<Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)
end
-- 计算可发动此卡的位置区域掩码
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	if e:GetHandler():IsLocation(LOCATION_ONFIELD) then return 0xff end
	-- 获取所有满足同纵列包含可夺取怪兽的对方怪兽
	local lg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 遍历符合条件的对方怪兽集合
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_ONFIELD,tp))
	end
	return zone
end
-- ①效果发动准备：检查发动位置与控制权变更条件，并设置控制权变更操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsLocation(LOCATION_HAND+LOCATION_SZONE) then return false end
		if c:IsLocation(LOCATION_SZONE) then
			local ct=c:GetColumnGroup():FilterCount(s.cfilter2,nil,tp)
			-- 在魔陷区发动时检查同纵列怪兽数量及怪兽区空位
			return ct>0 and ct<=Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)
		end
		-- 在手牌发动时检查对方场上是否存在可变更控制权的怪兽
		return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	end
	-- 获取对方场上所有可变更控制权的怪兽
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：获得怪兽控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- ①效果处理：获得与此卡相同纵列的对方怪兽控制权
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsLocation(LOCATION_ONFIELD) then
		local g=c:GetColumnGroup():Filter(s.cfilter2,nil,tp)
		if g:GetCount()>0 then
			-- 获得同纵列对方怪兽的控制权
			Duel.GetControl(g,tp)
		end
	end
end
-- ②效果发动条件：场上里侧表示的此卡因对方的效果送去墓地或除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- ②效果发动准备：检查怪兽区域空位及陷阱怪兽特召条件，设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡名规格的陷阱怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将自身作为效果怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否满足特殊召唤陷阱怪兽的条件
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT)
	-- 将自身以特定召唤类型表侧表示特殊召唤
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- ③效果生效条件：自身是通过其自身效果特殊召唤
function s.efcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 抗性过滤条件：不受对方发动的且位于同纵列场上卡片的效果影响
function s.efilter(e,te)
	-- 获取自身怪兽区域序号
	local seq1=aux.MZoneSequence(e:GetHandler():GetSequence())
	-- 获取发动效果卡片的区域序号
	local seq=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_SEQUENCE)
	if (te:GetActivateLocation()&LOCATION_ONFIELD)==0 then return false end
	-- 获取发动效果卡片对应的怪兽区/魔陷区列序号
	local seq2=aux.MZoneSequence(seq)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and seq1==4-seq2
end
