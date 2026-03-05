--紅き血染めのエルドリクシル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地把1只不死族怪兽特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
function c20612097.initial_effect(c)
	-- ①：从自己的卡组·墓地把1只不死族怪兽特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20612097,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20612097)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c20612097.target)
	e1:SetOperation(c20612097.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20612097,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20612097)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c20612097.settg)
	e2:SetOperation(c20612097.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在「黄金国巫妖」怪兽
function c20612097.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 过滤函数：检查卡组或墓地是否存在满足条件的不死族怪兽
function c20612097.spfilter(c,e,tp,check)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (check or c:IsSetCard(0x1142))
end
-- 效果的发动条件判断：检查场上是否有不死族怪兽且卡组或墓地是否有满足条件的怪兽
function c20612097.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查场上是否存在「黄金国巫妖」怪兽
		local chk1=Duel.IsExistingMatchingCard(c20612097.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组或墓地是否存在满足条件的怪兽
			and Duel.IsExistingMatchingCard(c20612097.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,chk1)
	end
	-- 设置连锁操作信息：确定要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：选择并特殊召唤符合条件的怪兽，并设置后续限制效果
function c20612097.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查场上是否存在「黄金国巫妖」怪兽
	local chk1=Duel.IsExistingMatchingCard(c20612097.filter,tp,LOCATION_MZONE,0,1,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20612097.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,chk1)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置限制效果：直到回合结束时自己不是不死族怪兽不能特殊召唤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c20612097.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制效果到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的过滤函数：不能特殊召唤非不死族怪兽
function c20612097.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
-- 过滤函数：检查卡组是否存在「黄金乡」魔法或陷阱卡
function c20612097.stfilter(c)
	return c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果的发动条件判断：检查场上是否有空位且卡组是否存在「黄金乡」魔法或陷阱卡
function c20612097.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组是否存在「黄金乡」魔法或陷阱卡
		and Duel.IsExistingMatchingCard(c20612097.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：选择并盖放符合条件的魔法或陷阱卡
function c20612097.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c20612097.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的魔法或陷阱卡盖放到场上
		Duel.SSet(tp,g)
	end
end
