--超栄養太陽
-- 效果：
-- ①：把自己场上1只2星以下的植物族怪兽解放才能把这张卡发动。把持有解放的怪兽的等级＋3以下的等级的1只植物族怪兽从手卡·卡组特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c28529976.initial_effect(c)
	-- ①：把自己场上1只2星以下的植物族怪兽解放才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28529976.target)
	e1:SetOperation(c28529976.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c28529976.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c28529976.descon2)
	e3:SetOperation(c28529976.desop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查场上是否存在满足条件的2星以下植物族怪兽，且该怪兽满足后续特殊召唤条件。
function c28529976.cfilter(c,e,tp,ft)
	return c:IsLevelBelow(2) and c:IsRace(RACE_PLANT)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查手卡或卡组中是否存在等级不超过解放怪兽等级+3的植物族怪兽。
		and Duel.IsExistingMatchingCard(c28529976.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c:GetLevel()+3,e,tp)
end
-- 过滤函数，检查手卡或卡组中是否存在满足条件的植物族怪兽，且可特殊召唤。
function c28529976.filter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时，检查是否满足解放条件并选择解放对象，然后进行解放操作。
function c28529976.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足发动条件，即场上存在可解放的怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c28529976.cfilter,1,nil,e,tp,ft) end
	-- 选择满足条件的1只怪兽进行解放。
	local rg=Duel.SelectReleaseGroup(tp,c28529976.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel()+3)
	-- 将选中的怪兽从场上解放。
	Duel.Release(rg,REASON_COST)
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理时，选择并特殊召唤满足条件的植物族怪兽。
function c28529976.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择满足条件的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,c28529976.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e:GetLabel(),e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
	end
end
-- 当此卡离开场上时，若目标怪兽在场则将其破坏。
function c28529976.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 当目标怪兽离开场上时，判断是否触发此效果。
function c28529976.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当目标怪兽离开场上时，将此卡破坏。
function c28529976.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
