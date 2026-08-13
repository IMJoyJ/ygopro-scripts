--ヘルフレイムバンシー
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只炎族怪兽加入手卡或送去墓地。
-- ②：这张卡被除外的场合，若自己场上有炎族怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力直到回合结束时上升自己的除外状态的怪兽数量×100。
local s,id,o=GetID()
-- 初始化卡片效果：启用苏生限制；添加以2只4星怪兽为素材的XYZ召唤手续；注册①效果（取除超量素材，从卡组选炎族怪兽加入手卡或送墓，1回合1次）与②效果（被除外且场上有炎族怪兽时特殊召唤并提升攻击力，1回合1次）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：用2只4星怪兽作为超量素材叠放（对应“4星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只炎族怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.scost)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，若自己场上有炎族怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力直到回合结束时上升自己的除外状态的怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：检查这张卡是否有1个超量素材，若有则取除1个超量素材作为代价。
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中的1只炎族怪兽，且该卡可以加入手卡或可以送去墓地。
function s.filter(c)
	return c:IsRace(RACE_PYRO) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果的发动条件：卡组中存在至少1只满足“炎族且可加入手卡或可送墓”的怪兽（不取对象，处理时选择）。
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组是否存在至少1张符合条件的炎族怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：从卡组选择1只符合条件的炎族怪兽；然后由玩家选择将其加入手卡或送去墓地，并执行相应处理（加入手卡时让对方确认卡牌）。
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家从卡组选择要操作（加入手卡或送去墓地）的炎族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组筛选出1只符合条件的炎族怪兽（由于效果不取对象，在处理时选择），并取得该卡。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	-- 让玩家在“加入手卡”或“送去墓地”之间选择；选项的可用性由该卡能否加入手卡/能否送去墓地决定。
	local op=aux.SelectFromOptions(tp,{tc:IsAbleToHand(),1190},{tc:IsAbleToGrave(),1191})
	if op==1 then
		-- 将选中的炎族怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的卡，以确认检索的卡片。
		Duel.ConfirmCards(1-tp,tc)
	-- 若玩家选择送去墓地，则将选中的炎族怪兽以效果原因送去墓地。
	else Duel.SendtoGrave(tc,REASON_EFFECT) end
end
-- 过滤条件：表侧表示且为炎族怪兽，用于检查自己场上是否存在炎族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
-- ②效果的发动条件：自己场上有至少1只表侧表示的炎族怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1只满足s.cfilter（表侧表示炎族怪兽）的怪兽，存在则②效果可发动。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标条件：此卡仍可特殊召唤，且自己主要怪兽区域有空位；满足后设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区域是否有空位，若没有空位则②效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设为“特殊召唤这张卡”1张，供后续效果检测（如对应特殊召唤的卡片等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：表侧表示的怪兽，用于统计除外状态的怪兽数量（以此提升攻击力）。
function s.afilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- ②效果处理：将这张卡以表侧攻击表示特殊召唤；若成功，则根据除外区的表侧怪兽数量，使其攻击力上升数量×100直到回合结束；随后完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与本效果关联，并作为特殊召唤的一步将其以表侧攻击表示特殊召唤；若不能（如已离场等）则中断处理。
	if not (c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)) then return end
	-- 统计自己除外区域表侧表示的怪兽数量，作为攻击力上升的数值依据。
	local ct=Duel.GetMatchingGroupCount(s.afilter,tp,LOCATION_REMOVED,0,nil)
	if ct>0 then
		-- 这个效果特殊召唤的这张卡的攻击力直到回合结束时上升自己的除外状态的怪兽数量×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤流程，使通过特殊召唤召唤的怪兽正式上场（与SpecialSummonStep配对使用）。
	Duel.SpecialSummonComplete()
end
