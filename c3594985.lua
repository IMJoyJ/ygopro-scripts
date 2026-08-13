--マジェスペクター・ドラコ
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「威风妖怪」卡或「龙剑士」卡存在的场合才能发动。从卡组把1张「威风妖怪」卡加入手卡。那之后，可以把自己的灵摆区域1张卡破坏。
-- 【怪兽效果】
-- 4星怪兽×2
-- 4星可以灵摆召唤的场合在额外卡组的表侧的这张卡可以灵摆召唤。这个卡名的①的怪兽效果1回合可以使用最多2次。
-- ①：这张卡在怪兽区域存在的状态，怪兽被解放的场合，把这张卡1个超量素材取除才能发动。从卡组把1只6星以下的魔法师族·风属性怪兽特殊召唤。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合或者被解放的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 注册该卡的所有卡片效果：为其添加超量召唤手续、苏生限制、灵摆属性，并依次注册灵摆检索效果、怪兽①的特召效果、怪兽②的破坏/解放后放置灵摆区域效果（破坏版和解放版）。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只4星怪兽为超量素材作超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽属性，但不注册灵摆卡作为魔法卡发动的效果（即灵摆区域的卡的发动效果）。
	aux.EnablePendulumAttribute(c,false)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域有「威风妖怪」卡或「龙剑士」卡存在的场合才能发动。从卡组把1张「威风妖怪」卡加入手卡。那之后，可以把自己的灵摆区域1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.srcon)
	e1:SetTarget(s.srtg)
	e1:SetOperation(s.srop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的怪兽效果1回合可以使用最多2次。①：这张卡在怪兽区域存在的状态，怪兽被解放的场合，把这张卡1个超量素材取除才能发动。从卡组把1只6星以下的魔法师族·风属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合或者被解放的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"在灵摆区域放置"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e4)
end
s.pendulum_level=4
-- 定义过滤函数：检查一张卡是否属于「龙剑士」（0xc7）或「威风妖怪」（0xd0）系列，用于判断灵摆区域中是否存在与灵摆效果发动条件相关的卡。
function s.cfilter(c)
	return c:IsSetCard(0xc7,0xd0)
end
-- 灵摆效果发动条件的判断函数：检查自己的灵摆区域是否存在另一张满足「龙剑士」或「威风妖怪」条件的卡（不含本卡）。
function s.srcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在至少1张不是本卡且属于「龙剑士」或「威风妖怪」系列的卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 定义检索过滤函数：目标卡必须是「威风妖怪」系列且能够加入手牌，用于灵摆效果从卡组检索。
function s.srfilter(c,oc)
	return c:IsSetCard(0xd0) and c:IsAbleToHand()
end
-- 灵摆效果发动时的目标合法性函数：在发动时（chk==0）检查卡组中是否存在可加入手牌的「威风妖怪」卡，若有则设置本次操作信息为从卡组加入1张手牌。
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时确认卡组中存在至少1张满足条件的「威风妖怪」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，标记本次效果包含从卡组将1张卡加入手牌，供后续时点/效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的实际处理：从卡组选择1张「威风妖怪」卡加入手牌，让对方确认并洗切手牌；之后可选择自己灵摆区域的1张卡破坏。
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家正在选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「威风妖怪」卡并取得这张卡。
	local tc=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 若选到了卡且成功以效果加入手牌并仍位于手牌，则继续执行后续处理（确认、洗牌、可选破坏）。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 让对方玩家确认检索加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 洗切自己的手牌，防止对方通过手牌顺序得知检索的卡。
		Duel.ShuffleHand(tp)
		-- 取得自己灵摆区域的全部卡，作为可选破坏的候选集合。
		local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		-- 如果自己灵摆区域有卡，且玩家选择‘是’，则进行后续的破坏处理。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把自己的灵摆区域1张卡破坏？"
			-- 弹出选择提示，提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续的破坏处理与前一段处理不再视为同时处理，以正确对应『那之后』的时点。
			Duel.BreakEffect()
			-- 手动显示被选为破坏对象的卡片的选中动画，并记录其为对象。
			Duel.HintSelection(sg)
			-- 以效果原因破坏选中的卡片。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 定义怪兽解放事件的过滤函数：被解放的卡属于怪兽（且不是从魔法陷阱区域解放的）或是从主要怪兽区域解放的卡，即排除从灵摆区域作为魔法卡被解放的情况。
function s.cfilter2(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- 怪兽效果①发动条件的判断：本次发生了解放事件且存在满足条件的被解放怪兽，并且被解放的怪兽不包括这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 怪兽效果①发动代价：取除这张卡的1个超量素材作为发动COST。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 提示玩家选择要取除的超量素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义特殊召唤过滤函数：选择等级6以下、魔法师族、风属性且可以被效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①发动时的目标合法性函数：检查自己场上是否有可用怪兽区域，且卡组中是否存在满足条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在满足特召条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，标记本次效果为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 怪兽效果①的实际处理：若场上仍有空位，从卡组选择1只符合条件的怪兽以表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查场上是否有怪兽区域空位，若没有则效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果②发动条件的判断：这张卡离场前位于怪兽区域且为表侧表示（即作为怪兽被破坏/解放）。注意：要求表侧表示来自脚本裁定。
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②发动时的目标合法性函数：检查自己灵摆区域是否存在至少1个空位。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己灵摆区域的左位或右位是否有空位可以放置这张卡。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的实际处理：如果这张卡仍与效果关联，则将其表侧表示放置到自己的灵摆区域。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域并表侧表示放置，同时立即适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
