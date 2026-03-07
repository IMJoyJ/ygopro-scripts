--レプティレス・メルジーヌ
-- 效果：
-- 爬虫类族调整＋调整以外的怪兽1只以上
-- 这张卡的②的效果在同一连锁上只能发动1次。
-- ①：只用爬虫类族怪兽为素材作同调召唤的这张卡不会被战斗·效果破坏。
-- ②：对方把怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从卡组把1只爬虫类族怪兽加入手卡。
function c32138660.initial_effect(c)
	-- 添加同调召唤手续，要求1只爬虫类族调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只用爬虫类族怪兽为素材作同调召唤的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32138660.indcon)
	e1:SetOperation(c32138660.indop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c32138660.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从卡组把1只爬虫类族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32138660,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c32138660.atkcon)
	e3:SetTarget(c32138660.atktg)
	e3:SetOperation(c32138660.atkop)
	c:RegisterEffect(e3)
	-- 检索满足条件的爬虫类族怪兽并加入手牌
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(32138660,2))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c32138660.thcon)
	e4:SetTarget(c32138660.thtg)
	e4:SetOperation(c32138660.thop)
	c:RegisterEffect(e4)
end
-- 检查同调召唤所用素材是否全部为爬虫类族怪兽，若是则标记为1，否则为0
function c32138660.valcheck(e,c)
	local g=c:GetMaterial()
	if g:FilterCount(Card.IsRace,nil,RACE_REPTILE)==#g then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为同调召唤且素材全部为爬虫类族
function c32138660.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 使该卡在战斗中不会被破坏，并提示其效果为‘只用爬虫类族怪兽为素材作同调召唤’
function c32138660.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使该卡在战斗中不会被破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(32138660,0))  --"只用爬虫类族怪兽为素材作同调召唤"
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	c:RegisterEffect(e2)
end
-- 判断是否为对方怪兽效果发动且该卡未在战斗中被破坏
function c32138660.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 选择对方场上1只表侧表示的攻击力不为0的怪兽作为对象
function c32138660.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为对方场上表侧表示的攻击力不为0的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 检查对方场上是否存在表侧表示的攻击力不为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的攻击力不为0的怪兽
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽的攻击力设为0
function c32138660.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的攻击力设为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断该卡是否为同调召唤且被对方送入墓地
function c32138660.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤出爬虫类族且能加入手牌的怪兽
function c32138660.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 设置检索操作信息，准备从卡组检索1只爬虫类族怪兽加入手牌
function c32138660.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的爬虫类族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32138660.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组中选择1只爬虫类族怪兽加入手牌并确认
function c32138660.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c32138660.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
