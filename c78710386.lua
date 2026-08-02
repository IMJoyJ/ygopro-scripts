--R.B.ファンク・ドック
-- 效果：
-- 作为这张卡发动时的效果处理：从卡组把「奏悦机组 疯克对接站」以外的1张「奏悦机组」卡加入手卡。
-- 每次对方场上的怪兽被战斗·效果破坏，自己回复500基本分。
-- 自己场上的表侧表示「奏悦机组」怪兽因卡的效果从场上离开的场合（伤害步骤除外）：可以从卡组把1只「奏悦机组」怪兽特殊召唤。「奏悦机组 疯克对接站」的这个效果1回合只能使用1次。
-- 「奏悦机组 疯克对接站」在1回合只能发动1张。
-- 
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 作为这张卡发动时的效果处理：从卡组把「奏悦机组 疯克对接站」以外的1张「奏悦机组」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 每次对方场上的怪兽被战斗·效果破坏，自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.reccon)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	-- 自己场上的表侧表示「奏悦机组」怪兽因卡的效果从场上离开的场合（伤害步骤除外）：可以从卡组把1只「奏悦机组」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检索目标：不是「奏悦机组 疯克对接站」且是「奏悦机组」卡，可以加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsAbleToHand()
end
-- 效果目标：检查卡组是否有可以加入手卡的检索目标，并设置加入手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张检索目标加入手卡并给对方确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：在怪兽区且控制权为对方的怪兽被战斗或效果破坏
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(1-tp)
end
-- 触发条件：事件相关的卡组中存在符合被破坏过滤条件的怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果处理：展示卡片并回复500基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 使玩家回复500基本分
	Duel.Recover(tp,500,REASON_EFFECT)
end
-- 过滤条件：原本在己方怪兽区表侧表示的「奏悦机组」卡因效果离场
function s.cspfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x1cf)
		and c:IsReason(REASON_EFFECT)
end
-- 触发条件：存在符合离场过滤条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cspfilter,1,nil,tp)
end
-- 特殊召唤过滤条件：是「奏悦机组」卡且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：检查场上是否有空格以及卡组是否有符合特召条件的怪兽，并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的主要怪兽区是否还有空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在1张符合特召过滤条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：检查怪兽区空格，选择1只符合条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家的怪兽区没有空格则不进行操作
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
