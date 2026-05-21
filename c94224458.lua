--白き宿命のエルドリクシル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·墓地把1只不死族怪兽特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
function c94224458.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只不死族怪兽特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94224458,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,94224458)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c94224458.target)
	e1:SetOperation(c94224458.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94224458,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,94224458)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c94224458.settg)
	e2:SetOperation(c94224458.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「黄金国巫妖」怪兽
function c94224458.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 过滤条件：手卡·墓地可以特殊召唤的不死族怪兽（若场上没有「黄金国巫妖」怪兽，则必须是「黄金国巫妖」怪兽）
function c94224458.spfilter(c,e,tp,check)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (check or c:IsSetCard(0x1142))
end
-- 效果①的发动准备与合法性检测
function c94224458.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在表侧表示的「黄金国巫妖」怪兽
		local chk1=Duel.IsExistingMatchingCard(c94224458.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有可用的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡·墓地是否存在满足特殊召唤条件的不死族怪兽
			and Duel.IsExistingMatchingCard(c94224458.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,chk1)
	end
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理逻辑
function c94224458.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 在效果处理时，再次检查自己场上是否存在表侧表示的「黄金国巫妖」怪兽
	local chk1=Duel.IsExistingMatchingCard(c94224458.filter,tp,LOCATION_MZONE,0,1,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只满足条件的不死族怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94224458.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,chk1)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c94224458.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该特殊召唤限制效果，使其对玩家生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能特殊召唤非不死族的怪兽
function c94224458.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
-- 过滤条件：卡组中可以盖放的「黄金乡」魔法·陷阱卡
function c94224458.stfilter(c)
	return c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动准备与合法性检测
function c94224458.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在可以盖放的「黄金乡」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c94224458.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理逻辑
function c94224458.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的魔法与陷阱区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张「黄金乡」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c94224458.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
