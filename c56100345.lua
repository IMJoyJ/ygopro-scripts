--サイバー・ダーク・ヴルム
-- 效果：
-- 这个卡名的②的效果在决斗中只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡在手卡·墓地存在，自己的场上或墓地有这张卡以外的机械族「电子」怪兽存在的场合，从手卡·卡组把1只「电子龙」怪兽送去墓地才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1张「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果，包括①效果（在场上·墓地当作「电子龙」使用）和②效果（手卡·墓地起动效果，送墓手卡·卡组「电子龙」怪兽特召自身，之后可回收墓地「电子」或「电子科技」魔陷）。
function s.initial_effect(c)
	-- 使这张卡在场上（怪兽区）和墓地存在时，卡名当作「电子龙」使用。
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果在决斗中只能使用1次。②：这张卡在手卡·墓地存在，自己的场上或墓地有这张卡以外的机械族「电子」怪兽存在的场合，从手卡·卡组把1只「电子龙」怪兽送去墓地才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1张「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示或墓地存在的、自身以外的机械族「电子」怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x93) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤效果的发动条件：自己场上或墓地存在这张卡以外的机械族「电子」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上或墓地是否存在至少1张这张卡以外的机械族「电子」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
end
-- 过滤条件：手卡或卡组中可以作为代价送去墓地的「电子龙」怪兽。
function s.costfilter(c)
	return c:IsSetCard(0x1093) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的发动代价：从手卡或卡组把1只「电子龙」怪兽送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡或卡组是否存在可送去墓地的「电子龙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「电子龙」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：自己墓地中可以加入手卡的「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡。
function s.thfilter(c)
	return c:IsSetCard(0x93,0x94) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 特殊召唤效果的发动目标：检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理：将自身特殊召唤，之后可以从自己墓地选择1张「电子」或「电子科技」魔法·陷阱卡加入手卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于原本区域且不受王家之谷影响，则将其特殊召唤，并判断是否特殊召唤成功。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己墓地中所有不受王家之谷影响且满足条件的「电子」或「电子科技」魔法·陷阱卡。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在满足条件的卡，则询问玩家是否要将卡加入手卡。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
			-- 提示玩家选择要加入手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			sg=sg:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续的加入手卡处理与特殊召唤不视为同时进行。
			Duel.BreakEffect()
			-- 将选中的魔法·陷阱卡加入手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
