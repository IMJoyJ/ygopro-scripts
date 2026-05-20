--古代遺跡の静粛
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在魔法与陷阱区域存在，场地区域有场地魔法卡被表侧表示放置的场合才能发动。从卡组把「古代遗迹的肃静」以外的1张「三形金字塔」魔法·陷阱卡加入手卡。
-- ②：自己场上的表侧表示的岩石族怪兽被战斗或者对方的效果破坏的场合才能发动。和破坏的怪兽卡名不同的1只「三形金字塔」怪兽从卡组特殊召唤。
function c64576557.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡在魔法与陷阱区域存在，场地区域有场地魔法卡被表侧表示放置的场合才能发动。从卡组把「古代遗迹的肃静」以外的1张「三形金字塔」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64576557,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,64576557)
	e2:SetCondition(c64576557.thcon)
	e2:SetTarget(c64576557.thtg)
	e2:SetOperation(c64576557.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的岩石族怪兽被战斗或者对方的效果破坏的场合才能发动。和破坏的怪兽卡名不同的1只「三形金字塔」怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64576557,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,64576558)
	e3:SetCondition(c64576557.spcon)
	e3:SetTarget(c64576557.sptg)
	e3:SetOperation(c64576557.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：在魔法与陷阱区域（场地区域）表侧表示存在的场地魔法卡
function c64576557.cfilter(c)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()==5 and c:IsType(TYPE_FIELD) and c:IsFaceup()
end
-- 检索效果的发动条件：移动的卡片中存在表侧表示放置到场地区域的场地魔法卡，且不包含这张卡自身
function c64576557.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64576557.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：卡组中「古代遗迹的肃静」以外的「三形金字塔」魔法·陷阱卡，且能加入手卡
function c64576557.thfilter(c)
	return c:IsSetCard(0xe2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(64576557) and c:IsAbleToHand()
end
-- 检索效果的靶向处理：检查卡组中是否存在满足条件的卡，并设置检索的操作信息
function c64576557.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在「古代遗迹的肃静」以外的「三形金字塔」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64576557.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体执行：从卡组选择1张满足条件的卡加入手卡，并给对方确认
function c64576557.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「三形金字塔」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c64576557.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：原本由自己控制、在怪兽区域表侧表示存在、因战斗或对方效果被破坏的岩石族怪兽
function c64576557.desfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_ROCK~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 特殊召唤效果的发动条件：自己场上表侧表示的岩石族怪兽被战斗或对方效果破坏
function c64576557.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64576557.desfilter,1,nil,tp)
end
-- 过滤条件：卡组中可以特殊召唤的「三形金字塔」怪兽，且其卡名与被破坏的怪兽不同
function c64576557.spfilter(c,e,tp,eg)
	-- 检查卡片是否为「三形金字塔」怪兽、是否能特殊召唤，且其卡名不属于被破坏的怪兽卡名
	return c:IsSetCard(0xe2) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.TriamidSpSummonType(c)) and not eg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 特殊召唤效果的靶向处理：检查自己场上是否有空位以及卡组中是否有可特召的怪兽，并设置特殊召唤的操作信息
function c64576557.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c64576557.desfilter,nil,tp)
		-- 检查自己场上是否有可用的怪兽区域空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 且卡组中存在满足特殊召唤条件的「三形金字塔」怪兽
			and Duel.IsExistingMatchingCard(c64576557.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,g)
	end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的具体执行：从卡组选择1只与被破坏怪兽卡名不同的「三形金字塔」怪兽特殊召唤
function c64576557.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=eg:Filter(c64576557.desfilter,nil,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特殊召唤条件的「三形金字塔」怪兽
	local tg=Duel.SelectMatchingCard(tp,c64576557.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g)
	if tg:GetCount()>0 then
		local sc=tg:GetFirst()
		-- 将选择的怪兽以表侧表示特殊召唤，并判断其是否为特殊召唤怪兽
		if Duel.SpecialSummon(tg,0,tp,tp,false,aux.TriamidSpSummonType(sc),POS_FACEUP) and aux.TriamidSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
