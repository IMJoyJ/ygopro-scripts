--ARG☆S－勇駿のアリオン
-- 效果：
-- 4星怪兽×2
-- 「阿尔戈☆群星-勇骏之阿里翁」1回合1次也能在自己场上的「阿尔戈☆群星」怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「阿尔戈☆群星」魔法卡加入手卡。
-- ②：自己·对方的准备阶段，把这张卡2个超量素材取除才能发动。从自己墓地把最多3张「阿尔戈☆群星」永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册XYZ召唤手续，允许在「阿尔戈☆群星」怪兽上面重叠来超量召唤
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在「阿尔戈☆群星」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「阿尔戈☆群星」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的准备阶段，把这张卡2个超量素材取除才能发动。从自己墓地把最多3张「阿尔戈☆群星」永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"表侧表示放置"
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「阿尔戈☆群星」怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c1)
end
-- 检查是否已使用过该效果，若未使用则注册效果标识
function s.xyzop(e,tp,chk)
	-- 检查是否已使用过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册效果标识，使该效果在本回合内只能使用一次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断是否为XYZ召唤成功时触发
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足条件的「阿尔戈☆群星」魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x1c1) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置效果发动的费用：移除2个超量素材
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤满足条件的「阿尔戈☆群星」永续陷阱卡
function s.pfilter(c,tp)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSetCard(0x1c1)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置效果发动的目标信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地是否有满足条件的永续陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 获取满足条件的永续陷阱卡组
	local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_GRAVE,0,nil,tp)
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行效果，选择并放置永续陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 计算最多可放置的永续陷阱卡数量
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),3)
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_GRAVE,0,1,ct,nil,tp)
	-- 遍历选中的永续陷阱卡
	for tc in aux.Next(g) do
		-- 将永续陷阱卡放置到场上的魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
