--紅き血染めのエルドリクシル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地把1只不死族怪兽特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
function c20612097.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从自己的卡组·墓地把1只不死族怪兽特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20612097,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20612097)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置②效果的发动代价：把墓地中的这张卡除外（使用通用除外代价函数aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c20612097.settg)
	e2:SetOperation(c20612097.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查怪兽是否为表侧表示的「黄金国巫妖」怪兽，用于判断自己场上是否存在「黄金国巫妖」怪兽。
function c20612097.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 特召候选过滤：怪兽必须是不死族且能够被特殊召唤；若check为false（即自己场上没有表侧「黄金国巫妖」），则还必须属于「黄金国巫妖」字段。
function c20612097.spfilter(c,e,tp,check)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (check or c:IsSetCard(0x1142))
end
-- ①效果发动时的目标合法性判定：检查场上是否有表侧「黄金国巫妖」以确定是否限定「黄金国巫妖」；确认主要怪兽区有空位且卡组·墓地存在可特召的不死族怪兽；登记特殊召唤的操作信息。
function c20612097.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测自己场上是否存在表侧表示的「黄金国巫妖」怪兽，以决定本次特召是否必须选择「黄金国巫妖」怪兽。
		local chk1=Duel.IsExistingMatchingCard(c20612097.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己主要怪兽区是否有可用的空格。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组·墓地是否存在满足特召条件的不死族怪兽（若场上无「黄金国巫妖」则必须为「黄金国巫妖」怪兽）。
			and Duel.IsExistingMatchingCard(c20612097.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,chk1)
	end
	-- 设置操作信息：本效果涉及从卡组·墓地特殊召唤1只怪兽，供后续发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理流程：若主要怪兽区有空位，根据场上是否有表侧「黄金国巫妖」选择卡组·墓地中可特召且不受「王家长眠之谷」影响的不死族怪兽（有限制时必须是「黄金国巫妖」）表侧特殊召唤；随后若该效果为魔法卡发动，则给自己附加直到回合结束时不能特殊召唤不死族以外怪兽的自肃。
function c20612097.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空格，若已无空位则本效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次检查自己场上是否有表侧「黄金国巫妖」，以决定选择怪兽时的字段限制。
	local chk1=Duel.IsExistingMatchingCard(c20612097.filter,tp,LOCATION_MZONE,0,1,nil)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·墓地选择1只满足特召条件且不受「王家长眠之谷」影响的不死族怪兽（若场上无「黄金国巫妖」则限定为「黄金国巫妖」怪兽）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20612097.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,chk1)
	if #g>0 then
		-- 将选择的怪兽表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 对应原文①的“这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。”以及②的“把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。”（代码包含自肃效果注册、自肃限制条件函数、②的盖放过滤与目标处理函数）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c20612097.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册到场上，使其对当前发动玩家生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃限制条件：若怪兽不是不死族，则不能将其特殊召唤。
function c20612097.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
-- ②的盖放过滤：卡组中属于「黄金乡」字段的魔法·陷阱卡，且能够盖放到魔法陷阱区。
function c20612097.stfilter(c)
	return c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动条件检测：魔陷区有空格，且卡组中存在符合条件的「黄金乡」魔法·陷阱卡。
function c20612097.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在符合条件的「黄金乡」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c20612097.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果处理：从卡组选择1张「黄金乡」魔法·陷阱卡盖放到自己场上。
function c20612097.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认魔陷区仍有空格，若已无空位则本效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张符合条件的「黄金乡」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c20612097.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡盖放到自己的魔法陷阱区。
		Duel.SSet(tp,g)
	end
end
