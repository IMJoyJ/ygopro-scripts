--Distrust Paranoia
local s,id,o=GetID()
-- 初始化卡片效果：注册①发动控制权变更陷阱效果、②被对方效果送墓/除外特召自身为陷阱怪兽效果、③陷阱怪兽状态下的抗性效果
function s.initial_effect(c)
	-- ①：这张卡发动的纵列有对方怪兽存在的场合才能发动。得到那目怪兽的控制权。
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
	-- ②：里侧表示盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。这张卡变成效果怪兽特殊召唤。
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
	-- 这个效果特殊召唤的这张卡不受和这张卡相同纵列的对方发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.efcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end
-- 可改变控制权的对方场上怪兽过滤条件
function s.cfilter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControlerCanBeChanged() and c:IsControler(1-tp)
end
-- 怪兽列可转移控制权过滤条件：同纵列存在可改变控制权的对方怪兽且怪兽区有空位
function s.cfilter(c,tp)
	-- 检查同纵列对方怪兽数量是否小于自己可用的怪兽区数量
	return c:IsControlerCanBeChanged() and c:GetColumnGroup():FilterCount(s.cfilter2,nil,tp)<Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)
end
-- 限定发动位置（LIMIT_ZONE）：返回符合条件的可用魔法与陷阱区域
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	if e:GetHandler():IsLocation(LOCATION_ONFIELD) then return 0xff end
	-- 获取对方场上所有同纵列怪兽可被夺取控制权的怪兽组
	local lg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 遍历满足条件的怪兽计算其对应纵列区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_ONFIELD,tp))
	end
	return zone
end
-- ①效果发动准备：确认发动位置与同纵列目标，设置控制权变更操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsLocation(LOCATION_HAND+LOCATION_SZONE) then return false end
		if c:IsLocation(LOCATION_SZONE) then
			local ct=c:GetColumnGroup():FilterCount(s.cfilter2,nil,tp)
			-- 从魔陷区发动时检查同纵列是否存在对方怪兽且怪兽区空位足够
			return ct>0 and ct<=Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)
		end
		-- 从手牌发动时检查对方场上是否存在可改变控制权的怪兽
		return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	end
	-- 获取对方场上所有可改变控制权的怪兽
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：得到指定怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- ①效果处理：得到与此卡相同纵列的对方怪兽的控制权
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsLocation(LOCATION_ONFIELD) then
		local g=c:GetColumnGroup():Filter(s.cfilter2,nil,tp)
		if g:GetCount()>0 then
			-- 得到同纵列对方怪兽的控制权
			Duel.GetControl(g,tp)
		end
	end
end
-- ②效果发动条件：里侧表示的此卡因对方效果从场上离开送墓或除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- ②效果发动准备：检查格子与可特召陷阱怪兽状态，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为陷阱怪兽（攻4000/守4000/10星/恶魔族/暗属性）特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将此卡赋予怪兽属性并特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否满足陷阱怪兽特殊召唤条件
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT)
	-- 以自身效果特殊召唤方式将此卡表侧表示特殊召唤
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- ③效果生效条件：此卡是由自身效果特殊召唤的
function s.efcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ③效果抗性过滤：不受与此卡处于相同纵列的对方在场上发动的效果影响
function s.efilter(e,te)
	-- 获取此卡当前在怪兽区的序号
	local seq1=aux.MZoneSequence(e:GetHandler():GetSequence())
	-- 获取发动效果的卡在场上的位置序号
	local seq=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_SEQUENCE)
	if (te:GetActivateLocation()&LOCATION_ONFIELD)==0 then return false end
	-- 将发动效果的位置序号转换为标准怪兽/魔陷区序号
	local seq2=aux.MZoneSequence(seq)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and seq1==4-seq2
end
