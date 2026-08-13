--ガーディアン・スライム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害计算时才能发动。这张卡的守备力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
-- ③：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把有「太阳神之翼神龙」的卡名记述的1张魔法·陷阱卡加入手卡。
function c15771991.initial_effect(c)
	-- 登记此卡的效果文本中记载了「太阳神之翼神龙」（卡号10000010），用于后续检索“有卡名记述”的卡片。
	aux.AddCodeList(c,10000010)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15771991,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15771991)
	e1:SetCondition(c15771991.spcon)
	e1:SetTarget(c15771991.sptg)
	e1:SetOperation(c15771991.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的自己·对方回合的伤害计算时才能发动。这张卡的守备力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15771991,1))
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,15771992)
	e2:SetCondition(c15771991.defcon)
	e2:SetOperation(c15771991.defop)
	c:RegisterEffect(e2)
	-- ③：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把有「太阳神之翼神龙」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15771991,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,15771993)
	e3:SetCondition(c15771991.thcon)
	e3:SetTarget(c15771991.thtg)
	e3:SetOperation(c15771991.thop)
	c:RegisterEffect(e3)
end
-- 发动条件判定：检查伤害承受方是自己（ep==tp）且伤害原因包含战斗或效果其中之一，即自己因战斗·效果受到伤害。
function c15771991.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 特殊召唤的发动目标设定：检查自己场上有可用的主要怪兽区且此卡能够被特殊召唤；若合法，则设置特殊召唤的操作信息。
function c15771991.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 合法性检查：要求自己场上存在可用怪兽区域，且这张卡能够被特殊召唤（不检查召唤条件，但会检查苏生限制）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣告本连锁处理将特殊召唤这张卡（数量1，对象为这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤的处理函数：若这张卡仍与效果相关联，则将其特殊召唤到自己场上。
function c15771991.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到发动者（tp）的场上，并正常进行特殊召唤合法性检查。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 伤害计算时效果发动条件：这张卡正与对方表侧表示怪兽进行战斗，且对方怪兽攻击力大于0。
function c15771991.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsFaceup() and bc:GetAttack()>0
end
-- 伤害计算时效果处理：若这张卡和对方怪兽均仍处于战斗关联且表侧表示，则给这张卡赋予一个仅在本伤害计算阶段有效的守备力上升效果，上升数值为对方怪兽当前攻击力。
function c15771991.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		-- ②：这张卡的守备力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
-- ③效果发动条件：这张卡是刚从手卡或场上被送去墓地，即满足“从手卡·场上送去墓地的场合”。
function c15771991.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 检索过滤器：用于筛选卡组中满足以下条件的卡：效果文本记载了「太阳神之翼神龙」、属于魔法·陷阱卡、且能够加入手卡。
function c15771991.thfilter(c)
	-- 筛选条件：卡名效果文本记述了「太阳神之翼神龙」（卡号10000010），类型为魔法·陷阱卡，并且可以被加入手卡。
	return aux.IsCodeListed(c,10000010) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③的发动目标设定：检查卡组中是否存在符合条件的检索对象，并设置操作信息为从卡组将1张卡加入手卡。
function c15771991.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：卡组中存在至少1张满足检索条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c15771991.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果会将1张卡从卡组加入手卡（具体卡在效果处理时选择，检索者tp，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的检索处理：提示玩家选择一张符合条件的魔法·陷阱卡，将其加入手卡并向对方展示。
function c15771991.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示信息，提示其选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c15771991.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择成功的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认被检索加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
