--ピース・オブ・スタチュー
-- 效果：
-- ①：这张卡发动后变成持有以下效果的效果怪兽（岩石族·地·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●自己·对方回合，支付800基本分才能发动（这个卡名的这个效果1回合只能使用1次）。「和平之像」以外的自己的墓地·除外状态的1张永续陷阱卡作为卡名当作「和平之像」使用的通常怪兽（岩石族·地·4星·攻/守1000）特殊召唤（不当作陷阱卡使用）。
local s,id,o=GetID()
-- 注册本卡的两个效果：e1为陷阱卡发动后变成效果怪兽并特殊召唤；e2为变成怪兽后在双方回合支付800LP从自己墓地·除外区特殊召唤1张永续陷阱卡作为「和平之像」通常怪兽。
function s.initial_effect(c)
	-- 将本卡卡号（即「和平之像」）加入代码列表，用于处理「和平之像」以外的判定以及卡名当作「和平之像」使用。
	aux.AddCodeList(c,id)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（岩石族·地·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●自己·对方回合，支付800基本分才能发动（这个卡名的这个效果1回合只能使用1次）。「和平之像」以外的自己的墓地·除外状态的1张永续陷阱卡作为卡名当作「和平之像」使用的通常怪兽（岩石族·地·4星·攻/守1000）特殊召唤（不当作陷阱卡使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 发动条件检测：确认本卡发动时没有需要检查的cost条件，自己的主要怪兽区有空位，且玩家能够将本卡以岩石族·地·4星·攻/守1800的效果陷阱怪兽形式特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己的主要怪兽区域是否有可用的空格，确保能够特殊召唤怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家能否将这张卡作为岩石族·地·4星·攻/守1800的效果陷阱怪兽特殊召唤（受格子和召唤限制影响）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置操作信息：本效果将进行特殊召唤，对象为本卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡本身变为效果陷阱怪兽（岩石族·地·4星·攻/守1800），并正面表示特殊召唤到自己的主要怪兽区域。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认玩家仍可特殊召唤该效果陷阱怪兽，若因故不能则本效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将自身以正面表示形式特殊召唤到自己的主要怪兽区，SUMMON_VALUE_SELF表示以自身效果进行的特殊召唤。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- e2的发动cost：支付800基本分。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检测：检查自己能否支付800基本分。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分作为发动代价。
	Duel.PayLPCost(tp,800)
end
-- 筛选符合条件的卡：不是「和平之像」、是永续陷阱卡、处于表侧表示（墓地/除外区的表侧状态），且能够被特殊召唤为岩石族·地·4星·攻/守1000的通常陷阱怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsFaceupEx()
		-- 检查玩家能否将那1张永续陷阱卡作为岩石族·地·4星·攻/守1000的通常陷阱怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH)
end
-- e2的发动条件：自己的主要怪兽区有空位，且自己墓地或除外区存在满足s.spfilter条件的卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地·除外区是否存在至少1张满足s.spfilter条件的永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行特殊召唤，处理时从墓地·除外区选择1张卡，目标位置为墓地·除外区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理：选择1张符合条件的永续陷阱卡，将其变成卡名当作「和平之像」使用的通常陷阱怪兽（岩石族·地·4星·攻/守1000）并特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认主要怪兽区仍有空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认玩家仍能将选择的卡特殊召唤为通常陷阱怪兽，若不能则中止。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 实际从自己墓地·除外区选择1张满足条件且不受「王家长眠之谷」影响的永续陷阱卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_EARTH,RACE_ROCK,4,1000,1000)
		-- 作为卡名当作「和平之像」使用的通常怪兽（岩石族·地·4星·攻/守1000）特殊召唤（不当作陷阱卡使用）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET)
		e1:SetValue(id)
		tc:RegisterEffect(e1)
		-- 将选择的卡以正面表示形式特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
