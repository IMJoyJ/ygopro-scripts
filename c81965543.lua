--Distrust Paranoia
local s,id,o=GetID()
-- 声明initial_effect函数，注册夺取控制权、特殊召唤和不受效果影响的效果
function s.initial_effect(c)
	-- 在和对方怪兽相同纵列的自己的魔法与陷阱区域才能将这张卡发动。得到和这张卡相同纵列的对方怪兽的控制权。
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
	-- 这张卡被送去墓地或除外的场合才能发动。这张卡当作怪兽特殊召唤。
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
	-- 自身的效果特殊召唤的这张卡不受和这张卡不同纵列发动的对方的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.efcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end
-- 过滤条件：判断是否为对方场上可以改变控制权的怪兽
function s.cfilter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControlerCanBeChanged() and c:IsControler(1-tp)
end
-- 过滤条件：判断是否有可夺取控制权的怪兽且当前有空余怪兽区
function s.cfilter(c,tp)
	-- 判断该卡同纵列是否有对方可改变控制权的怪兽且有空余怪兽区
	return c:IsControlerCanBeChanged() and c:GetColumnGroup():FilterCount(s.cfilter2,nil,tp)<Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)
end
-- 获取满足发动条件的可发动区域
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	if e:GetHandler():IsLocation(LOCATION_ONFIELD) then return 0xff end
	-- 获取有可夺取控制权的怪兽的同纵列群
	local lg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 遍历满足条件的卡片组，获取可用区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_ONFIELD,tp))
	end
	return zone
end
-- 效果发动目标设定，限制发动区域并设置夺取控制权的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsLocation(LOCATION_HAND+LOCATION_SZONE) then return false end
		if c:IsLocation(LOCATION_SZONE) then
			local ct=c:GetColumnGroup():FilterCount(s.cfilter2,nil,tp)
			-- 判断同纵列中存在对方怪兽并且有足够的可用怪兽区
			return ct>0 and ct<=Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)
		end
		-- 判断对方场上是否存在可以改变控制权的怪兽
		return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	end
	-- 获取对方场上所有可以改变控制权的怪兽
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	-- 设置夺取控制权的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：夺取该卡同纵列的对方怪兽的控制权
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsLocation(LOCATION_ONFIELD) then
		local g=c:GetColumnGroup():Filter(s.cfilter2,nil,tp)
		if g:GetCount()>0 then
			-- 夺取满足条件的对方怪兽控制权
			Duel.GetControl(g,tp)
		end
	end
end
-- 判断卡片是否是从场上里侧表示被对方的效果送去墓地或除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 判断是否有怪兽区空位并且可以作为陷阱怪兽特殊召唤，设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 判断自己场上是否有可用的怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断能否以暗属性恶魔族10星攻守4000的陷阱怪兽状态特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置特殊召唤此卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：判断是否能特召并作为效果怪兽特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若无法作为陷阱怪兽特殊召唤则直接返回不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT)
	-- 将此卡作为效果怪兽特殊召唤
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断这张卡是否是通过自身效果特殊召唤的
function s.efcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：判断对方发动的效果是否与此卡处于不同纵列
function s.efilter(e,te)
	-- 获取这张卡所在的怪兽区序号
	local seq1=aux.MZoneSequence(e:GetHandler():GetSequence())
	-- 获取连锁中发动效果的卡片的序号
	local seq=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_SEQUENCE)
	if (te:GetActivateLocation()&LOCATION_ONFIELD)==0 then return false end
	-- 计算对方发动的效果的序号并返回是否为不同纵列
	local seq2=aux.MZoneSequence(seq)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and seq1==4-seq2
end
