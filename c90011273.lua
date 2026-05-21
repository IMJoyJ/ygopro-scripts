--ブリーチヴァレル・ドラゴン
-- 效果：
-- 包含「弹丸」怪兽的龙族·暗属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「枪管」魔法·陷阱卡加入手卡。
-- ②：自己·对方回合，以自己场上1只暗属性怪兽为对象才能发动。那只怪兽的攻击力上升500。作为对象的怪兽不存在的场合，可以作为代替从卡组把1只「弹丸」怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①效果（连接召唤成功时检索「枪管」魔陷）和②效果（自由时点上升暗属性怪兽攻击力，若对象不存在则可从卡组守备表示特召「弹丸」怪兽）。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只怪兽，其中必须包含「弹丸」怪兽，且素材必须是暗属性·龙族怪兽。
	aux.AddLinkProcedure(c,s.mfilter,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「枪管」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，以自己场上1只暗属性怪兽为对象才能发动。那只怪兽的攻击力上升500。作为对象的怪兽不存在的场合，可以作为代替从卡组把1只「弹丸」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤连接素材：必须是暗属性，且是龙族怪兽（或具有特定效果可作为龙族素材的怪兽）。
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and (c:IsLinkRace(RACE_DRAGON) or c:IsHasEffect(77189532))
end
-- 连接素材额外检查：素材组中必须存在至少1只「弹丸」怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x102)
end
-- ①效果发动条件：这张卡是连接召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果检索卡片过滤条件：卡组中的「枪管」魔法·陷阱卡，且能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x10f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target）：检查卡组是否存在可检索卡，并设置操作信息为将卡组的卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「枪管」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（Operation）：从卡组选择1张「枪管」魔法·陷阱卡加入手卡，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「枪管」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的对象过滤条件：自己场上表侧表示的暗属性怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果的发动准备（Target）：处理取对象相关的逻辑，检查已选择的对象是否依然合法。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		and s.atkfilter(chkc) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在至少1只满足条件的暗属性怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的暗属性怪兽作为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果代替特召的过滤条件：卡组中可以守备表示特殊召唤的「弹丸」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的处理（Operation）：若对象怪兽存在则使其攻击力上升500；若对象怪兽不存在，则可选择从卡组守备表示特召1只「弹丸」怪兽。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		if tc:IsFaceup() then
			-- 那只怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(500)
			tc:RegisterEffect(e1)
		end
	-- （作为对象的怪兽不存在的场合）检查自己场上是否有空余的怪兽区域。
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否选择作为代替从卡组特殊召唤怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足条件的「弹丸」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
