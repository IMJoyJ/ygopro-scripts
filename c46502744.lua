--応戦するG
-- 效果：
-- ①：包含把怪兽特殊召唤效果的魔法卡由对方发动时才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡的①的效果特殊召唤的这张卡在怪兽区域存在，被送去墓地的卡不去墓地而除外。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「应战的G」以外的1只攻击力1500以下的昆虫族·地属性怪兽加入手卡。
function c46502744.initial_effect(c)
	-- ①：包含把怪兽特殊召唤效果的魔法卡由对方发动时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c46502744.spcon)
	e1:SetTarget(c46502744.sptg)
	e1:SetOperation(c46502744.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡的①的效果特殊召唤的这张卡在怪兽区域存在，被送去墓地的卡不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e2:SetCondition(c46502744.remcon)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「应战的G」以外的1只攻击力1500以下的昆虫族·地属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c46502744.thcon)
	e3:SetTarget(c46502744.thtg)
	e3:SetOperation(c46502744.thop)
	c:RegisterEffect(e3)
end
-- 效果发动时，对方发动了包含特殊召唤的魔法卡
function c46502744.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
-- 效果处理时，确认是否满足特殊召唤条件
function c46502744.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，将自身从手牌特殊召唤到场上
function c46502744.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤步骤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		c:RegisterFlagEffect(46502745,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE-RESET_LEAVE,0,1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果适用条件：自身被①效果特殊召唤过
function c46502744.remcon(e)
	return e:GetHandler():GetFlagEffect(46502745)~=0
end
-- 效果发动条件：自身从场上送去墓地
function c46502744.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤函数：昆虫族·地属性·攻击力1500以下且非应战的G
function c46502744.thfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAttackBelow(1500) and not c:IsCode(46502744) and c:IsAbleToHand()
end
-- 效果处理时，确认是否满足检索条件
function c46502744.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46502744.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组检索符合条件的怪兽并加入手牌
function c46502744.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c46502744.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
