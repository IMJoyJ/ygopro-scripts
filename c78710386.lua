--R.B.ファンク・ドック
-- 效果：
-- 作为这张卡发动时的效果处理：从卡组把「奏悦机组 疯克对接站」以外的1张「奏悦机组」卡加入手卡。
-- 每次对方场上的怪兽被战斗·效果破坏，自己回复500基本分。
-- 自己场上的表侧表示「奏悦机组」怪兽因卡的效果从场上离开的场合（伤害步骤除外）：可以从卡组把1只「奏悦机组」怪兽特殊召唤。「奏悦机组 疯克对接站」的这个效果1回合只能使用1次。
-- 「奏悦机组 疯克对接站」在1回合只能发动1张。
-- 
local s,id,o=GetID()
-- 初始化卡片效果：注册发动时检索卡组「奏悦机组」卡效果、对方怪兽破坏回复基本分效果、自己「奏悦机组」怪兽因效果离场特召卡组怪兽效果
function s.initial_effect(c)
	-- 卡片发动时的效果处理：从卡组把「奏悦机组 疯克对接站」以外的1张「奏悦机组」卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 场地效果：每次对方场上的怪兽被战斗·效果破坏，自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.reccon)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	-- 场地效果：自己场上的表侧表示「奏悦机组」怪兽因卡的效果从场地离开的场合（伤害步骤除外）才能发动。从卡组把1只「奏悦机组」怪兽特殊召唤。
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
-- 检索过滤条件：同名卡以外的「奏悦机组」卡且可加入手牌
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsAbleToHand()
end
-- 发动准备：检查卡组是否存在可检索的「奏悦机组」卡，设置加入手牌操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在符合检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动处理：从卡组把1张同名卡以外的「奏悦机组」卡加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择加入手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「奏悦机组」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏过滤条件：原本在对方场上怪兽区且因战斗或效果被破坏
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(1-tp)
end
-- 回复效果发动条件：存在满足被破坏条件的对方怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 回复效果处理：提示卡片发动并回复自己500基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片效果发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 自己回复500基本分
	Duel.Recover(tp,500,REASON_EFFECT)
end
-- 离场过滤条件：原本由自己控制的表侧表示「奏悦机组」怪兽因效果从怪兽区离场
function s.cspfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x1cf)
		and c:IsReason(REASON_EFFECT)
end
-- 特召效果发动条件：存在满足效果离场条件的「奏悦机组」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cspfilter,1,nil,tp)
end
-- 特召过滤条件：「奏悦机组」怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召效果发动准备：检查怪兽区空位及卡组是否存在可特召怪兽，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组中是否存在满足特召条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特召效果处理：从卡组选择1只「奏悦机组」怪兽表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，无空位则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「奏悦机组」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
