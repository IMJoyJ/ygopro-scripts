--水霊媒師エリア
-- 效果：
-- 这个卡名在规则上也当作「灵使」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只水属性怪兽丢弃才能发动。把持有这张卡以外的丢弃的怪兽的等级以上的等级的1只水属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把水属性以外的怪兽的效果发动。
-- ②：自己的水属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
local s,id,o=GetID()
-- 初始效果注册函数：为这张卡创建并注册两个效果，①是丢弃自身和水属性怪兽从卡组检索水属性怪兽的起动效果，②是场上的水属性怪兽被战斗破坏时从手卡特殊召唤的诱发效果。
function s.initial_effect(c)
	-- ①：从手卡把这张卡和1只水属性怪兽丢弃才能发动。把持有这张卡以外的丢弃的怪兽的等级以上的等级的1只水属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把水属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的水属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 丢弃代价的过滤函数：候选怪兽需为水属性且可丢弃，并且卡组中存在至少1只等级不低于它且能加入手卡的水属性怪兽，以保证丢弃后能检索。
function s.dfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
		-- 额外检查卡组中是否确实存在满足检索条件的卡，确保代价可以支付。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 检索目标的过滤函数：水属性、等级不低于所丢弃怪兽的等级、并且可以加入手卡。
function s.thfilter(c,lv)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(lv) and c:IsAbleToHand()
end
-- 代价函数：先检查自身可丢弃且手卡中存在满足条件的水属性怪兽，再让玩家选择一张丢弃怪兽，记录其等级，然后将自身和该怪兽一起送入墓地作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检测：自身可以丢弃，并且手卡中存在除自身以外满足丢弃条件的水属性怪兽，且卡组中有可检索目标。
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,c,tp) end
	-- 弹出选择提示，提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择一张除自身以外、满足dfilter的水属性怪兽作为丢弃代价。
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,c,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将自身和选择的水属性怪兽送入墓地，作为发动代价（COST）并视为丢弃。
	Duel.SendtoGrave(g+c,REASON_COST+REASON_DISCARD)
end
-- 目标函数：确认已经完成代价支付，并且卡组中存在可检索的目标，然后设置将1只水属性怪兽加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 进一步确认卡组中存在等级满足条件、可加入手卡的水属性怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 将本次操作信息登记为从卡组把1张卡加入手卡，用于后续效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1只满足条件的水属性怪兽加入手卡，向对方确认；然后给自己设置直到回合结束不能发动水属性以外的怪兽效果的限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只等级不低于label、水属性且可加入手卡的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		-- 将选择的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这次加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把水属性以外的怪兽的效果发动。②：自己的水属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使其对tp玩家生效，直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：如果试图发动的效果是怪兽效果，且该怪兽不是水属性，则禁止发动。
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_WATER)
end
-- 用于判断被战斗破坏的怪兽是否为水属性且之前控制者是tp（自己），以此满足②的发动条件。
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp)
end
-- 发动条件：这次战斗破坏的怪兽组中，至少存在1只水属性且之前控制者为tp的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 目标函数：检查自己可以被特殊召唤且主要怪兽区有空位，满足则设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的主要怪兽区是否有空余格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己的主要怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡没有因处理过程中的其他效果离场或失去联系，若仍关联则进行特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
