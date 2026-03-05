--ガーディアン・スライム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害计算时才能发动。这张卡的守备力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
-- ③：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把有「太阳神之翼神龙」的卡名记述的1张魔法·陷阱卡加入手卡。
function c15771991.initial_effect(c)
	-- 记录该卡具有「太阳神之翼神龙」的卡名记述
	aux.AddCodeList(c,10000010)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡和对方怪兽进行战斗的伤害计算时才能发动。这张卡的守备力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
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
-- 判断是否为己方受到战斗或效果伤害
function c15771991.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 设置特殊召唤的处理信息
function c15771991.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域进行特殊召唤且该卡可被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c15771991.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以正面表示形式特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否处于战斗状态且对方怪兽存在且为表侧表示且攻击力大于0
function c15771991.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsFaceup() and bc:GetAttack()>0
end
-- 设置守备力提升效果
function c15771991.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		-- 将该卡的守备力提升为对方怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否从手卡或场上送去墓地
function c15771991.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 定义检索过滤条件：卡名为「太阳神之翼神龙」且为魔法或陷阱卡
function c15771991.thfilter(c)
	-- 判断卡名为「太阳神之翼神龙」且为魔法或陷阱卡
	return aux.IsCodeListed(c,10000010) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索处理信息
function c15771991.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c15771991.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作
function c15771991.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c15771991.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
