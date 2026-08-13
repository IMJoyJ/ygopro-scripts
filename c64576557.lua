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
-- 过滤函数：判断该卡是否为位于场地区域（魔陷区5号位）的表侧表示场地魔法卡
function c64576557.cfilter(c)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()==5 and c:IsType(TYPE_FIELD) and c:IsFaceup()
end
-- ①效果发动条件：本次移动的卡中存在被表侧表示放置到场地区域的场地魔法卡，且移动的卡不是这张卡自身
function c64576557.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64576557.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 检索过滤函数：「三形金字塔」魔法·陷阱卡，且不是「古代遗迹的肃静」，并且可以加入手卡
function c64576557.thfilter(c)
	return c:IsSetCard(0xe2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(64576557) and c:IsAbleToHand()
end
-- ①效果目标设定：确认卡组存在可加入手卡的「三形金字塔」魔法·陷阱卡，并设置卡组检索的操作信息
function c64576557.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动可行性检查：自己卡组存在至少1张满足条件的可加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64576557.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣言将要从卡组把1张卡加入手卡（具体卡在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：让玩家从卡组选1张「三形金字塔」魔法·陷阱卡加入手卡，并展示给对方确认
function c64576557.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「三形金字塔」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c64576557.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断被破坏的卡是否为自己场上被破坏的表侧表示岩石族怪兽，且破坏原因是战斗或对方的效果
function c64576557.desfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_ROCK~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②效果发动条件：本次被破坏的卡中存在满足条件的自己场上表侧表示岩石族怪兽
function c64576557.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64576557.desfilter,1,nil,tp)
end
-- 特殊召唤过滤函数：「三形金字塔」怪兽，可以被特殊召唤，且卡名与被破坏的怪兽不同
function c64576557.spfilter(c,e,tp,eg)
	-- 判定该卡为「三形金字塔」怪兽、可以特殊召唤，并且与被破坏的怪兽卡名不同
	return c:IsSetCard(0xe2) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.TriamidSpSummonType(c)) and not eg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- ②效果目标设定：确认主要怪兽区有空位且卡组存在可特殊召唤的「三形金字塔」怪兽，并设置特殊召唤的操作信息
function c64576557.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c64576557.desfilter,nil,tp)
		-- 检查自己主要怪兽区是否有可用的空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组是否存在至少1张满足条件的可特殊召唤的「三形金字塔」怪兽
			and Duel.IsExistingMatchingCard(c64576557.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,g)
	end
	-- 设置操作信息：宣言将要从卡组把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：主要怪兽区无空位则中断；否则从卡组选1只卡名与被破坏怪兽不同的「三形金字塔」怪兽表侧表示特殊召唤，若为特殊召唤怪兽则完成正规召唤手续
function c64576557.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再确认主要怪兽区有空位，没有则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=eg:Filter(c64576557.desfilter,nil,tp)
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「三形金字塔」怪兽
	local tg=Duel.SelectMatchingCard(tp,c64576557.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g)
	if tg:GetCount()>0 then
		local sc=tg:GetFirst()
		-- 将选择的怪兽表侧表示特殊召唤到自己场上，若成功且该怪兽属于特殊召唤怪兽，则执行CompleteProcedure完成其正规出场手续
		if Duel.SpecialSummon(tg,0,tp,tp,false,aux.TriamidSpSummonType(sc),POS_FACEUP)>0 and aux.TriamidSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
