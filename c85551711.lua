--虚空の黒魔導師
-- 效果：
-- 魔法师族7星怪兽×2
-- ①：只要持有超量素材的这张卡在怪兽区域存在，自己在对方回合可以把速攻魔法卡以及陷阱卡从手卡发动。那个发动之际把这张卡1个超量素材取除。
-- ②：超量召唤的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。从手卡·卡组把1只魔法师族·暗属性怪兽特殊召唤。那之后，可以选场上1张卡破坏。
function c85551711.initial_effect(c)
	-- 为卡片添加超量召唤手续：魔法师族7星怪兽×2。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),7,2)
	c:EnableReviveLimit()
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，自己在对方回合可以把速攻魔法卡以及陷阱卡从手卡发动。那个发动之际把这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85551711,2))  --"适用「虚空之黑魔导师」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(c85551711.handcon)
	e1:SetCost(c85551711.handcost)
	e1:SetValue(85551711)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，自己在对方回合可以把速攻魔法卡以及陷阱卡从手卡发动。那个发动之际把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(85551711)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	-- ②：超量召唤的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。从手卡·卡组把1只魔法师族·暗属性怪兽特殊召唤。那之后，可以选场上1张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(85551711,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c85551711.spcon)
	e5:SetTarget(c85551711.sptg)
	e5:SetOperation(c85551711.spop)
	c:RegisterEffect(e5)
end
-- 手卡发动效果的条件函数：必须在对方回合。
function c85551711.handcon(e)
	-- 检查当前回合玩家是否为对方玩家（即在对方回合）。
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 过滤自己场上具有「虚空之黑魔导师」效果且可以取除超量素材的怪兽。
function c85551711.similarfilter(c,tp)
	return c:IsHasEffect(85551711) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 手卡发动效果的费用/动作处理：从自身或场上其他适用该效果的怪兽上取除1个超量素材。
function c85551711.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 获取自己场上除自身以外、适用该效果且可以取除超量素材的其他怪兽。
	local g=Duel.GetMatchingGroup(c85551711.similarfilter,tp,LOCATION_MZONE,0,c,tp)
	if #g>0 then
		-- 提示玩家选择要取除超量素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
		local tc=(g+c):Select(tp,1,1,nil):GetFirst()
		tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件：超量召唤的这张卡被对方效果送去墓地或被战斗破坏送去墓地。
function c85551711.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ((rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE))
		or c:IsReason(REASON_BATTLE)) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤手卡·卡组中可以特殊召唤的魔法师族·暗属性怪兽。
function c85551711.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位及是否存在可特召的怪兽，并设置操作信息）。
function c85551711.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足特殊召唤条件的魔法师族·暗属性怪兽。
		and Duel.IsExistingMatchingCard(c85551711.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤及后续破坏效果的执行函数。
function c85551711.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域空格，若无可用空格则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的魔法师族·暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c85551711.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取场上的所有卡片（作为后续破坏效果的候选对象）。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将选中的怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场上是否存在卡片，并询问玩家是否选择场上1张卡破坏。
		and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(85551711,0)) then  --"是否选场上1张卡破坏？"
		-- 中断当前效果处理，使特殊召唤与后续的破坏处理不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,1,1,nil)
		-- 选中要破坏的卡片并向双方玩家展示（显示选择框）。
		Duel.HintSelection(sg)
		-- 因效果将选中的卡片破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
