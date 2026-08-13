--森羅の姫芽宮
-- 效果：
-- 1星怪兽×2
-- 「森罗的姬芽宫」的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。自己卡组最上面的卡翻开。翻开的卡是魔法·陷阱卡的场合，那张卡加入手卡。不是的场合，那张卡送去墓地。
-- ②：从手卡以及这张卡以外的自己场上的表侧表示怪兽之中把1只植物族怪兽送去墓地，以自己墓地1只「森罗」怪兽为对象才能发动。那只怪兽特殊召唤。
function c33909817.initial_effect(c)
	-- 为「森罗的姬芽宫」添加XYZ召唤手续：用任意2只1星怪兽叠放作为XYZ素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。自己卡组最上面的卡翻开。翻开的卡是魔法·陷阱卡的场合，那张卡加入手卡。不是的场合，那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33909817,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33909817)
	e1:SetCost(c33909817.cost)
	e1:SetTarget(c33909817.target)
	e1:SetOperation(c33909817.operation)
	c:RegisterEffect(e1)
	-- ②：从手卡以及这张卡以外的自己场上的表侧表示怪兽之中把1只植物族怪兽送去墓地，以自己墓地1只「森罗」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33909817,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,33909818)
	e2:SetCost(c33909817.spcost)
	e2:SetTarget(c33909817.sptg)
	e2:SetOperation(c33909817.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：判定是否可以从这张卡上取除1个超量素材；实际发动时取除这张卡1个超量素材。
function c33909817.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动条件判定：确认自己卡组顶端1张卡可以被翻开处理（能送去墓地），且卡组中存在能够加入手卡的卡（以对应翻开的卡为魔法·陷阱卡时加入手卡的情况）。
function c33909817.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以将卡组最上方1张卡送去墓地（满足①效果中“不是的场合送去墓地”的处理前提）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己卡组中是否存在至少1张能够加入手卡的卡（对应翻开的卡为魔法·陷阱卡时加入手卡的可能）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行①效果：翻开自己卡组最上方1张卡，若为魔法·陷阱卡且能加入手卡则加入手卡，否则送去墓地；处理时禁止自动洗牌，并根据结果洗切手卡或送墓。
function c33909817.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己能否将卡组最上方1张卡送去墓地，若不能则效果处理中止。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向双方玩家确认并展示自己卡组最上方1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的那1张卡作为本次效果的处理对象。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsAbleToHand() then
		-- 禁用本次操作结束后的自动洗切卡组检测（因为从卡组顶端取卡后需要保持卡组顺序或手动处理）。
		Duel.DisableShuffleCheck()
		-- 将翻开的魔法·陷阱卡加入其持有者的手卡（效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 手动洗切自己的手卡（由于从卡组向手卡加入了卡，确保手卡顺序随机）。
		Duel.ShuffleHand(tp)
	else
		-- 禁用本次操作结束后的自动洗切卡组检测（在送墓分支中，从卡组顶送墓不改变卡组剩余顺序）。
		Duel.DisableShuffleCheck()
		-- 将翻开的非魔法·陷阱卡（怪兽卡）作为效果处理并以“翻开”为由送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 定义可作为②代价的植物族怪兽的筛选条件：必须为手卡中的植物族怪兽或自己场上表侧表示的植物族怪兽，且可以作为代价送去墓地；若当前主要怪兽区没有空位，则只能选择位于主怪兽区的怪兽（sequence<5），避免选择额外怪兽区导致特殊召唤时无空位。
function c33909817.cfilter(c,ft)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_PLANT) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- ②效果的发动代价：从手卡以及这张卡以外的自己场上的表侧表示怪兽中选择1只植物族怪兽送入墓地；判定阶段确认存在这样的卡，实际发动时选择并送入墓地作为代价。
function c33909817.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区的可用空格数量，用于判断代价选择范围及后续特殊召唤是否可行。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_HAND+LOCATION_MZONE
	if ft==0 then loc=LOCATION_MZONE end
	-- 判定代价支付条件：需要有非负的怪兽区域空位（ft>-1）且存在符合条件的植物族怪兽可送去墓地。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c33909817.cfilter,tp,loc,0,1,e:GetHandler(),ft) end
	-- 向玩家显示“选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己手卡和场上（不含这张卡）的表侧表示植物族怪兽中选择1张作为代价。
	local g=Duel.SelectMatchingCard(tp,c33909817.cfilter,tp,loc,0,1,1,e:GetHandler(),ft)
	-- 将选择的植物族怪兽以代价原因送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义可作为②特殊召唤对象的墓地怪兽的筛选条件：属于「森罗」系列，且能由该效果特殊召唤（满足召唤条件和苏生限制）。
function c33909817.filter(c,e,tp)
	return c:IsSetCard(0x90) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择：以自己墓地1只符合条件的「森罗」怪兽为对象，并设置对应特殊召唤的操作信息；同时进行发动条件检查。
function c33909817.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33909817.filter(chkc,e,tp) end
	-- 判定阶段检查自己墓地是否存在1只能够作为对象并被特殊召唤的「森罗」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c33909817.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的「森罗」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c33909817.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息，声明将要把1只对象怪兽特殊召唤，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果处理：获取对象怪兽，若对象仍与该效果关联，则将其特殊召唤到自己场上。
function c33909817.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽（墓地中的「森罗」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动者场上，并检查其召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
