--ARG☆S－勇駿のアリオン
-- 效果：
-- 4星怪兽×2
-- 「阿尔戈☆群星-勇骏之阿里翁」1回合1次也能在自己场上的「阿尔戈☆群星」怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「阿尔戈☆群星」魔法卡加入手卡。
-- ②：自己·对方的准备阶段，把这张卡2个超量素材取除才能发动。从自己墓地把最多3张「阿尔戈☆群星」永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 为这张卡注册超量召唤手续（普通4星怪兽×2，以及1回合1次在自己场上的「阿尔戈☆群星」怪兽上重叠的特殊方式），并注册①超量召唤成功时检索「阿尔戈☆群星」魔法卡、②准备阶段取除2个超量素材从墓地放置「阿尔戈☆群星」永续陷阱卡的两个效果。
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
-- 特殊超量召唤手续的超量素材过滤条件：选择自己场上的表侧表示「阿尔戈☆群星」怪兽作为重叠对象。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c1)
end
-- 作为追加的特殊超量召唤手续操作：检查本回合是否已使用过该特殊方式（誓约），使用后设置1回合1次的标志，防止重复利用。
function s.xyzop(e,tp,chk)
	-- 发动/适用前的条件判定：只有当当前玩家本回合没有对应的标志时，才允许选择这种特殊超量召唤方式。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为当前玩家注册一个结束阶段重置的誓约标志，记录本回合已经使用过以「阿尔戈☆群星」怪兽上重叠来超量召唤的特殊方式。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果①的发动条件：这张卡是以超量召唤方式成功特殊召唤的。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①检索对象的过滤条件：必须是「阿尔戈☆群星」魔法卡，并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1c1) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果①的发动目标设定：确认卡组存在可检索的「阿尔戈☆群星」魔法卡，并设置从卡组将1张加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①的发动合法性检查：卡组中是否存在至少1张「阿尔戈☆群星」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把卡组中的1张魔法卡加入持有者的手卡（用于连锁和效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：玩家选择1张「阿尔戈☆群星」魔法卡加入手卡，并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「阿尔戈☆群星」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送去（加入）其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手卡的那张卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价：从这张卡上取除2个超量素材（作为效果发动COST）。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果②放置对象的过滤条件：是「阿尔戈☆群星」永续陷阱卡，不是禁止卡，且场上可以拥有该卡（不存在同名卡限制）。
function s.pfilter(c,tp)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSetCard(0x1c1)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果②的发动目标判定：自己魔陷区有空格，且墓地存在至少1张符合条件的「阿尔戈☆群星」永续陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己魔法与陷阱区域是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 进一步检查墓地是否存在至少1张满足s.pfilter条件的「阿尔戈☆群星」永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 取得墓地中所有符合条件的「阿尔戈☆群星」永续陷阱卡，作为可能处理的卡片集合。
	local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_GRAVE,0,nil,tp)
	-- 设置操作信息：标记墓地中的这些卡为“离开墓地”的对象，数量为1（通常用于王家长眠之谷等交互检测）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②处理：若自己魔陷区有空位，从墓地选择最多3张符合条件的「阿尔戈☆群星」永续陷阱卡表侧表示放置到自己的魔陷区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认魔陷区仍有空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 计算实际可放置数量：取当前魔陷区空格数和3之间的较小值。
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),3)
	-- 显示“请选择要放置到场上的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从墓地选择1到ct张满足条件且不受王家长眠之谷影响的「阿尔戈☆群星」永续陷阱卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_GRAVE,0,1,ct,nil,tp)
	-- 遍历选中的每张卡。
	for tc in aux.Next(g) do
		-- 将当前遍历到的卡表侧表示放置到自己的魔法与陷阱区域，并立刻适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
