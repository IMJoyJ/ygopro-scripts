--ソウル・オブ・スタチュー
-- 效果：
-- 这张卡发动后变成怪兽卡（岩石族·光·4星·攻1000/守1800）在自己的怪兽卡区域特殊召唤。只要这张卡在场上当作怪兽使用而存在，这张卡以外的当作怪兽使用的陷阱卡被对方破坏送去自己墓地的场合，可以不送去墓地在魔法与陷阱卡区域盖放。这张卡也当作陷阱卡使用。
function c49514333.initial_effect(c)
	-- 这张卡发动后变成怪兽卡（岩石族·光·4星·攻1000/守1800）在自己的怪兽卡区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c49514333.target)
	e1:SetOperation(c49514333.activate)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上当作怪兽使用而存在，这张卡以外的当作怪兽使用的陷阱卡被对方破坏送去自己墓地的场合，可以不送去墓地在魔法与陷阱卡区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetCondition(c49514333.repcon)
	e2:SetTarget(c49514333.reptg)
	e2:SetValue(c49514333.repval)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
end
-- 该函数是这张卡发动时的条件判定函数：在发动时（chk==0）确认能否将自身特殊召唤为怪兽，需满足当前处于cost检查阶段、主怪兽区有空位且玩家可以特殊召唤这张陷阱怪兽。
function c49514333.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区域是否存在空位，用于判定能否将这张卡特殊召唤到自己的怪兽区。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp能否将这张卡以岩石族·光·4星·攻击力1000/守备力1800的效果陷阱怪兽形式特殊召唤，确保特殊召唤规则允许。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,49514333,0,TYPES_EFFECT_TRAP_MONSTER,1000,1800,4,RACE_ROCK,ATTRIBUTE_LIGHT) end
	-- 设置本次连锁的处理信息，声明此效果包含一次特殊召唤，对象为这张卡自身，数量为1，使系统能正确识别该特殊召唤操作并用于连锁发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 该函数是这张卡发动后的效果处理函数，实际将这张卡变成怪兽卡并特殊召唤到自己场上。
function c49514333.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时再次检查是否仍可特殊召唤（如格子是否被占用、是否受到特殊召唤限制），若无法达成则中止后续处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,49514333,0,TYPES_EFFECT_TRAP_MONSTER,1000,1800,4,RACE_ROCK,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区，召唤类型标记为自身效果特殊召唤（SUMMON_VALUE_SELF），不检查召唤条件但检查苏生限制。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 代替效果的条件判断：确认这张卡确实是通过自身效果被特殊召唤为陷阱怪兽（召唤类型为SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF），即只在这张卡作为怪兽存在于场上时适用。
function c49514333.repcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 代替效果的过滤条件：筛选出本应被对方破坏后送去自己墓地、位于怪兽区域且表侧表示、原本持有者为自己、原类型为陷阱卡、可以重新覆盖回魔法与陷阱区域、且不包含这张卡自身的陷阱怪兽。
function c49514333.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetDestination()==LOCATION_GRAVE and c:GetLeaveFieldDest()==0 and c:IsReason(REASON_DESTROY)
		and c:GetReasonPlayer()==1-tp and c:GetOwner()==tp and bit.band(c:GetOriginalType(),TYPE_TRAP)~=0 and c:IsCanTurnSet()
end
-- 该函数是代替送去墓地效果的处理函数：先检查符合条件的卡数量和魔陷区空位；询问玩家是否适用；若同意则将符合条件的卡移动到魔法与陷阱区域并里侧盖放，同时记录到LabelObject中供Value函数判断。
function c49514333.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c49514333.repfilter,e:GetHandler(),tp)
		-- 判定存在至少1张符合条件的陷阱怪兽，且自己的魔法与陷阱区域剩余空位不少于需要移动的卡数量，否则无法执行盖放。
		return count>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=count
	end
	-- 弹出是否使用「灵魂之像」的效果的确认对话框，玩家选择“是”时才执行代替送去墓地的处理。
	if Duel.SelectYesNo(tp,aux.Stringid(49514333,0)) then  --"是否要使用「灵魂之像」的效果？"
		local container=e:GetLabelObject()
		container:Clear()
		local g=eg:Filter(c49514333.repfilter,e:GetHandler(),tp)
		local tc=g:GetFirst()
		while tc do
			-- 将符合条件的陷阱怪兽移动到自己的魔法与陷阱区域，先以表侧表示放置。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			tc=g:GetNext()
		end
		-- 将刚移动到魔法与陷阱区域的卡片全部改为里侧表示，实现在魔法与陷阱卡区域的盖放。
		Duel.ChangePosition(g,POS_FACEDOWN)
		container:Merge(g)
		return true
	end
	return false
end
-- 作为EFFECT_SEND_REPLACE的Value函数，判断某张将被送去墓地的卡是否已在LabelObject记录的集合中；若在则返回真，使该卡不送去墓地而执行上述移动盖放处理。
function c49514333.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end
