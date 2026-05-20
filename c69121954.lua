--ダイナレスラー・テラ・パルクリオ
-- 效果：
-- 「恐龙摔跤手」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把「世界恐龙摔跤」发动的场合，以自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡作为连接素材送去墓地的场合，以自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。这个回合，自己不是「恐龙摔跤手」怪兽不能特殊召唤。
function c69121954.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：需要2只「恐龙摔跤手」怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x11a),2,2)
	-- ①：自己把「世界恐龙摔跤」发动的场合，以自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69121954,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,69121954)
	e1:SetCondition(c69121954.thcon)
	e1:SetTarget(c69121954.thtg)
	e1:SetOperation(c69121954.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合，以自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。这个回合，自己不是「恐龙摔跤手」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,69121955)
	e2:SetCondition(c69121954.spcon)
	e2:SetTarget(c69121954.sptg)
	e2:SetOperation(c69121954.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己发动了「世界恐龙摔跤」的效果。
function c69121954.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(90173539)
end
-- 效果①的过滤条件：自己墓地的「恐龙摔跤手」怪兽，且能加入手卡。
function c69121954.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x11a) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择：检查并选择自己墓地1只「恐龙摔跤手」怪兽作为对象。
function c69121954.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69121954.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的「恐龙摔跤手」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c69121954.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「恐龙摔跤手」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c69121954.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理：将作为对象的怪兽加入手牌。
function c69121954.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：此卡作为连接素材送去墓地的场合。
function c69121954.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 效果②的过滤条件：自己墓地的「恐龙摔跤手」怪兽，且能以守备表示特殊召唤。
function c69121954.spfilter(c,e,tp)
	return c:IsSetCard(0x11a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与目标选择：检查怪兽区域空位并选择自己墓地1只「恐龙摔跤手」怪兽作为对象。
function c69121954.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c69121954.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只可特殊召唤的「恐龙摔跤手」怪兽。
		and Duel.IsExistingTarget(c69121954.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「恐龙摔跤手」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c69121954.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将选中的1张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：将对象怪兽效果无效守备表示特殊召唤，并施加本回合只能特殊召唤「恐龙摔跤手」怪兽的限制。
function c69121954.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧守备表示特殊召唤（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
	-- 这个回合，自己不是「恐龙摔跤手」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c69121954.splimit)
	-- 注册全局效果，限制玩家本回合的特殊召唤。
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的过滤函数：非「恐龙摔跤手」怪兽不能特殊召唤。
function c69121954.splimit(e,c)
	return not c:IsSetCard(0x11a)
end
