--クロノダイバー・パワーリザーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成通常怪兽（念动力族·暗·4星·攻1900/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从自己的手卡·卡组·墓地把1只机械族「时间潜行者」怪兽特殊召唤。
-- ②：有魔法卡和陷阱卡在作为超量素材中的超量怪兽在自己场上存在的场合，把墓地的这张卡除外才能发动。场上1张卡除外。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①效果（e1）为发动后变成通常怪兽特殊召唤，并可再从手卡·卡组·墓地追加特殊召唤机械族「时间潜行者」怪兽；②效果（e2）为在满足条件时把墓地中的这张卡除外并除外场上1张卡；两个效果均设置了1回合1次的限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡发动后变成通常怪兽（念动力族·暗·4星·攻1900/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从自己的手卡·卡组·墓地把1只机械族「时间潜行者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成通常怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：有魔法卡和陷阱卡在作为超量素材中的超量怪兽在自己场上存在的场合，把墓地的这张卡除外才能发动。场上1张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上1张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 设置②效果的发动代价为将墓地中的这张卡除外，aux.bfgcost封装了“除外自身作为COST”的通用处理。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件检查：在效果发动时确认能否通过代价检查、自己场上是否有空余怪兽区域、以及自己能否将这张卡当作通常怪兽特殊召唤；只有全部满足时才能发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在空闲的怪兽区域，用于接下来特殊召唤这张卡（变成陷阱怪兽后占用怪兽区）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能够将这张卡作为通常怪兽（念动力族·暗·4星·攻1900/守2500）特殊召唤到场上，即验证特殊召唤手续是否可行。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x126,TYPES_NORMAL_TRAP_MONSTER,1900,2500,4,RACE_PSYCHO,ATTRIBUTE_DARK) end
	-- 设置操作信息，声明本次效果处理中会将这张卡自身特殊召唤（数量为1），供其他卡的效果（如星尘龙、王家长眠之谷等）进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义追加特殊召唤的候选过滤条件：怪兽必须是机械族、卡名属于「时间潜行者」（setcode=0x126），并且可以被效果特殊召唤（不无视召唤条件和苏生限制）。
function s.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(0x126) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的实际处理：先将这张卡变成通常怪兽（念动力族·暗·4星·攻1900/守2500）并特殊召唤；成功后再确认场上仍有空格且存在符合条件的候选怪兽，由玩家选择是否追加特殊召唤1只机械族「时间潜行者」。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认玩家仍能特殊召唤这张陷阱怪兽；若不能（比如怪兽区无空位或受其他限制），则终止整个①效果的处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x126,TYPES_NORMAL_TRAP_MONSTER,1900,2500,4,RACE_PSYCHO,ATTRIBUTE_DARK) then return end
	local c=e:GetHandler()
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤到自己怪兽区域；若特殊召唤失败（返回0），则不再进行后续的追加特殊召唤处理。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 检索自己手卡、卡组、墓地中所有满足s.filter条件的机械族「时间潜行者」怪兽，生成候选集合g；同时使用aux.NecroValleyFilter排除因王家长眠之谷而不能进行墓地区域特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
	-- 确认自己场上仍有空余怪兽区域、存在候选怪兽，并且玩家选择“是”之后，才进行追加特殊召唤；否则不执行后续选怪处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把怪兽特殊召唤？"
		-- 向玩家显示“请选择要特殊召唤的卡”的选卡提示，为接下来从候选组中选择怪兽做准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使追加特殊召唤与之前的特殊召唤被视为不同时处理（错开时点），避免错过时点或产生错误的同时处理。
		Duel.BreakEffect()
		-- 将玩家选中的那只机械族「时间潜行者」怪兽以表侧表示特殊召唤到自己场上（不无视召唤条件与苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义条件过滤函数：检查一只怪兽是否为表侧表示的超量怪兽，并且其超量素材中同时存在至少1张魔法卡和至少1张陷阱卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SPELL)
		and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- ②效果的发动条件：自己场上存在至少1只满足s.cfilter的超量怪兽，即素材中同时有魔法卡和陷阱卡的超量怪兽在场。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 通过过滤器检查自己怪兽区域是否存在至少1只符合条件（素材同时含魔法卡和陷阱卡的超量怪兽）的怪兽，存在则满足②效果的发动条件。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动时的目标合法性检查：先获取双方场上所有可以除外的卡，若至少存在1张，则允许发动，并设置操作信息为除外1张。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有当前可以被除外的卡（包括怪兽区域和魔法陷阱区域的卡），构成候选集合g。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，声明本次效果将除外场上1张卡（候选集合为g，数量为1），供连锁检测和相关效果进行响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的实际处理：由玩家从双方场上选择1张可以除外的卡，并将该卡以表侧表示除外，完成“场上1张卡除外”的效果。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要除外的卡”的选择提示，引导玩家从场上选择除外对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张满足Card.IsAbleToRemove的卡，作为本次除外的对象（效果处理时选择，属于不取对象的处理方式）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 手动显示被选中卡片的选中动画，并将这些卡记录为本次效果涉及的对象，使观感与对象化处理一致。
		Duel.HintSelection(g)
		-- 将选中的那张卡以表侧表示除外，除外原因记为效果，完成②效果的最终处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
