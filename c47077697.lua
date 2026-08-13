--呪念の化身ウルボヌス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把自己场上1只爬虫类族怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降300。
-- ③：把自己场上1只怪兽解放才能发动。对方场上的全部怪兽的攻击力·守备力直到回合结束时下降解放的怪兽的原本攻击力数值。
function c47077697.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：把自己场上1只爬虫类族怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47077697,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,47077697)
	e1:SetCost(c47077697.spcost)
	e1:SetTarget(c47077697.sptg)
	e1:SetOperation(c47077697.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
	local e3=Effect.Clone(e2)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 这个卡名的①③的效果1回合各能使用1次。③：把自己场上1只怪兽解放才能发动。对方场上的全部怪兽的攻击力·守备力直到回合结束时下降解放的怪兽的原本攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47077697,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,47077698)
	e4:SetCost(c47077697.thcost)
	e4:SetTarget(c47077697.thtg)
	e4:SetOperation(c47077697.thop)
	c:RegisterEffect(e4)
end
-- ①效果的解放怪兽过滤器：要求该怪兽是爬虫类族，且解放后我方仍有怪兽区空格，同时该怪兽为我方控制或表侧表示。
function c47077697.cfilter(c,tp)
	-- 判断该怪兽是爬虫类族，且解放该怪兽后我方场上有空余的怪兽区可用于特殊召唤这张卡。
	return c:IsRace(RACE_REPTILE) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的发动代价：选择并解放自己场上1只爬虫类族怪兽，且需确保解放后有怪兽区空格。
function c47077697.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己场上存在至少1只满足cfilter条件的可解放爬虫类族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47077697.cfilter,1,nil,tp) end
	-- 弹出“请选择要解放的卡”的提示，让玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只满足cfilter条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c47077697.cfilter,1,1,nil,tp)
	-- 将选择的怪兽作为效果发动COST解放。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标判定：确认这张卡本身可以被特殊召唤，并设置特殊召唤的操作信息。
function c47077697.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：本次操作包含特殊召唤，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤。
function c47077697.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的解放怪兽过滤器：要求怪兽的卡面攻击力大于0，且该怪兽为我方控制或表侧表示。
function c47077697.rfilter(c,tp)
	return c:GetTextAttack()>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- ③效果的发动代价：选择并解放自己场上1只卡面攻击力大于0的怪兽，记录其原本攻击力作为下降数值。
function c47077697.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己场上存在至少1只满足rfilter条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47077697.rfilter,1,nil,tp) end
	-- 弹出“请选择要解放的卡”的提示，让玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只满足rfilter条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c47077697.rfilter,1,1,nil,tp)
	-- 将选择的怪兽作为效果发动COST解放。
	Duel.Release(g,REASON_COST)
	local tc=g:GetFirst()
	local atk=tc:GetBaseAttack()
	e:SetLabel(atk)
end
-- 对方怪兽过滤器：用于判断对方场上是否存在（表侧表示且攻击力>0）或守备力>0的怪兽。
function c47077697.adfilter(c)
	return c:IsFaceup() and c:GetAttack()>0 or c:GetDefense()>0
end
-- ③效果的目标判定：确认对方场上存在至少1只满足adfilter条件的怪兽（有可下降的攻击力或守备力）。
function c47077697.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：判断对方怪兽区是否存在至少1只满足adfilter条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c47077697.adfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- ③效果处理：获取解放怪兽的原本攻击力，对对方场上所有表侧表示怪兽给予攻击力·守备力下降效果，持续到回合结束。
function c47077697.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabel()
	-- 获取对方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力·守备力直到回合结束时下降解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
