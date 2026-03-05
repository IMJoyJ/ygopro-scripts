--シトリスの蟲惑魔
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：持有超量素材的这张卡不受和给这张卡作为超量素材中的怪兽相同种族的怪兽（除这张卡外）发动的效果以及陷阱卡的效果影响。
-- ②：把这张卡1个超量素材取除才能发动。从卡组把1只「虫惑魔」怪兽加入手卡。
-- ③：原本持有者是对方的怪兽被效果所送去墓地的场合或者所除外的场合才能发动。选那之内的1只作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化效果，添加XYZ召唤手续并注册三个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用4星怪兽叠放，最少2只
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
	-- 注册合并的延迟事件，监听送去墓地和除外事件
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
-- 效果条件：持有超量素材
function s.imcon(e)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0
end
-- 效果值：免疫效果过滤器
function s.efilter(e,re)
	if re:IsActiveType(TYPE_TRAP) then return true end
	local g=e:GetHandler():GetOverlayGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
	local race=0
	-- 遍历超量素材中的怪兽
	for tc in aux.Next(g) do
		race=race|tc:GetOriginalRace()
	end
	local rc=re:GetHandler()
	return re:GetOwner()~=e:GetOwner() and race~=0
		and rc:IsRace(race) and re:IsActivated()
end
-- 效果Cost：去除1个超量素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤器：虫惑魔族怪兽
function s.thfilter(c)
	return c:IsSetCard(0x108a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果Target：检索1只虫惑魔族怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果Operation：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果Target过滤器：对方怪兽被效果送入墓地或除外
function s.cfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsType(TYPE_MONSTER)
		and c:GetOwner()==1-tp and c:IsReason(REASON_EFFECT+REASON_REDIRECT)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c:IsFaceupEx() and c:IsCanOverlay()
end
-- 效果Target：设置目标怪兽
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,tp)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and #g>0 end
	-- 设置连锁处理的目标卡
	Duel.SetTargetCard(g)
end
-- 效果Operation：选择并作为超量素材叠放
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.cfilter,nil,tp)
	-- 过滤不受王家长眠之谷影响的卡
	local mg=g:Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	if #mg>0 and c:IsRelateToChain() then
		-- 提示选择作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local og=mg:Select(tp,1,1,nil)
		-- 将卡叠放为超量素材
		Duel.Overlay(c,og)
	end
end
