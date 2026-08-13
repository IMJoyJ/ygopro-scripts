--アポピスの化神
-- 效果：
-- ①：自己·对方的主要阶段才能把这张卡发动。这张卡变成通常怪兽（爬虫类族·地·4星·攻1600/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
function c28649820.initial_effect(c)
	-- ①：自己·对方的主要阶段才能把这张卡发动。这张卡变成通常怪兽（爬虫类族·地·4星·攻1600/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c28649820.condition)
	e1:SetTarget(c28649820.target)
	e1:SetOperation(c28649820.activate)
	c:RegisterEffect(e1)
end
-- 此函数为效果的发动条件，判断当前是否处于自己或对方的主要阶段（主要阶段1或主要阶段2），满足时才允许发动此卡。
function c28649820.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2，即将此卡的发动时机限制在双方的主要阶段。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 发动合法性检测：确认满足前提检查、自己主怪兽区域有空位，且玩家能够将这张卡以爬虫类族·地·4星·攻1600/守1800的通常陷阱怪兽形式特殊召唤；若可发动则登记特殊召唤的操作信息。
function c28649820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可用的主要怪兽区域空格，确保这张卡发动后能特殊召唤到怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将这张卡作为指定数值与属性的通常陷阱怪兽（爬虫类族·地·4星·攻1600/守1800）特殊召唤，用于防止在不能特殊召唤怪兽的卡组或场地条件下发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28649820,0,TYPES_NORMAL_TRAP_MONSTER,1600,1800,4,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 登记本次连锁的操作信息，标明此效果将进行特殊召唤，处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：在效果处理时再次确认特殊召唤仍然可行，若可行则将这张卡变为通常陷阱怪兽并特殊召唤到自己的怪兽区域。
function c28649820.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前再次检查玩家是否仍然可以特殊召唤该陷阱怪兽，若不能则直接终止处理，不进行特殊召唤。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,28649820,0,TYPES_NORMAL_TRAP_MONSTER,1600,1800,4,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区域，作为通常陷阱怪兽存在（同时也当作陷阱卡使用）。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
