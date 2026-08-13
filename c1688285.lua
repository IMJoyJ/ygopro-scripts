--シトリスの蟲惑魔
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：持有超量素材的这张卡不受和给这张卡作为超量素材中的怪兽相同种族的怪兽（除这张卡外）发动的效果以及陷阱卡的效果影响。
-- ②：把这张卡1个超量素材取除才能发动。从卡组把1只「虫惑魔」怪兽加入手卡。
-- ③：原本持有者是对方的怪兽被效果所送去墓地的场合或者所除外的场合才能发动。选那之内的1只作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化此卡效果：添加XYZ召唤手续（4星怪兽×2），并注册效果①的免疫、效果②的检索、效果③的叠放，同时为③注册合并延迟事件。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用等级4的怪兽2只作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不受和给这张卡作为超量素材中的怪兽相同种族的怪兽（除这张卡外）发动的效果以及陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。从卡组把1只「虫惑魔」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 为这张卡注册合并延迟事件：将‘被效果送去墓地’和‘被效果除外’合并为一个自定义事件码，用于③效果在同一连锁中只触发一次。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_TO_GRAVE,EVENT_REMOVE})
	-- ③：原本持有者是对方的怪兽被效果所送去墓地的场合或者所除外的场合才能发动。选那之内的1只作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.mttg)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end
-- ①效果的适用条件：仅当这张卡持有超量素材时，免疫效果才适用。
function s.imcon(e)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0
end
-- ①效果的免疫判定：陷阱卡效果直接免疫；对怪兽效果，则计算本卡超量素材中怪兽的原始种族集合，若效果来源卡不是本卡、拥有该种族之一且效果已发动，则使该效果对本卡无效。
function s.efilter(e,re)
	if re:IsActiveType(TYPE_TRAP) then return true end
	local g=e:GetHandler():GetOverlayGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
	local race=0
	-- 遍历超量素材中的怪兽卡，累加它们的原始种族。
	for tc in aux.Next(g) do
		race=race|tc:GetOriginalRace()
	end
	local rc=re:GetHandler()
	return re:GetOwner()~=e:GetOwner() and race~=0
		and rc:IsRace(race) and re:IsActivated()
end
-- ②效果的发动代价：从这张卡上取除1个超量素材（若不能取除则无法发动）。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的检索过滤条件：选择卡组中1张‘虫惑魔’怪兽卡且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x108a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件与处理信息：发动时检查卡组中是否存在符合条件的虫惑魔怪兽，并设置本次操作将1张卡从卡组加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件（chk==0）：确认卡组中至少存在1张满足s.thfilter的虫惑魔怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果处理时将1张卡从卡组加入手牌（CATEGORY_TOHAND），供连锁相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：提示玩家选择1张符合条件的虫惑魔怪兽，将其加入手牌并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足s.thfilter的虫惑魔怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者手牌（nil表示加入原持有者手牌），原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认刚刚加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的过滤条件：怪兽不是衍生物、是怪兽卡、原本持有者为对方、因效果或效果改变去向被送去墓地/除外、当前位于墓地或除外区、为表侧表示且可以作为超量素材。
function s.cfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsType(TYPE_MONSTER)
		and c:GetOwner()==1-tp and c:IsReason(REASON_EFFECT+REASON_REDIRECT)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c:IsFaceupEx() and c:IsCanOverlay()
end
-- ③效果的发动条件与对象设定：从触发事件中筛出满足条件的怪兽，若本卡是XYZ怪兽且存在至少1只，则将它们全部设为关联对象。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,tp)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and #g>0 end
	-- 将满足条件的怪兽设置为当前连锁的对象，使它们与效果建立关联，便于处理时判断是否仍然可用。
	Duel.SetTargetCard(g)
end
-- ③效果处理：从仍与连锁相关的可选怪兽中选1只（排除受王家长眠之谷影响的卡），叠放在这张卡下面作为超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.cfilter,nil,tp)
	-- 进一步筛选：保留与当前连锁有关联且不受王家长眠之谷效果影响的怪兽卡。
	local mg=g:Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	if #mg>0 and c:IsRelateToChain() then
		-- 显示选择提示‘请选择要作为超量素材的卡’。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local og=mg:Select(tp,1,1,nil)
		-- 将选中的卡叠放在这张卡下方作为超量素材。
		Duel.Overlay(c,og)
	end
end
