--レプティレス・メルジーヌ
-- 效果：
-- 爬虫类族调整＋调整以外的怪兽1只以上
-- 这张卡的②的效果在同一连锁上只能发动1次。
-- ①：只用爬虫类族怪兽为素材作同调召唤的这张卡不会被战斗·效果破坏。
-- ②：对方把怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从卡组把1只爬虫类族怪兽加入手卡。
function c32138660.initial_effect(c)
	-- 为这张卡添加同调召唤手续：素材为“爬虫类族调整 + 调整以外的怪兽1只以上”。
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
	-- 只用爬虫类族怪兽为素材作同调召唤的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c32138660.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 这张卡的②的效果在同一连锁上只能发动1次。②：对方把怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
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
	-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从卡组把1只爬虫类族怪兽加入手卡。
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
-- 检查本次同调召唤的素材是否全部为爬虫类族，将结果（1是/0否）记录到e1的Label中，供后续①效果判定使用。
function c32138660.valcheck(e,c)
	local g=c:GetMaterial()
	if g:FilterCount(Card.IsRace,nil,RACE_REPTILE)==#g then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断这张卡是否为只用爬虫类族怪兽为素材作同调召唤，是则允许赋予破坏抗性。
function c32138660.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 为这张卡注册不会被战斗破坏和不会被效果破坏的永续效果，并设置为不可被无效，效果持续到这张卡离场等标准重置时机。
function c32138660.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 不会被战斗破坏
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
-- ②效果的发动条件：对方发动怪兽效果时，且这张卡没有处于战斗破坏确定状态，才能发动。
function c32138660.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的目标选择：选择对方场上1只表侧表示且攻击力不为0的怪兽作为对象。
function c32138660.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 校验连锁处理时的对象：该对象必须是对方场上表侧表示且攻击力不为0的怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 效果发动时检查对方场上是否存在符合条件的表侧表示且攻击力不为0的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只对方场上表侧表示且攻击力不为0的怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：将对象怪兽的攻击力变成0（通过赋予最终攻击力0的永续效果）。
function c32138660.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选择的第一个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：这张卡以同调召唤状态从自己场上被对方送去墓地。
function c32138660.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 检索过滤器：选择卡组中1只爬虫类族怪兽且能加入手卡的卡。
function c32138660.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- ③效果的目标：从卡组检索1只爬虫类族怪兽加入手卡，并设置对应操作信息。
function c32138660.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认卡组中是否存在至少1只符合条件的爬虫类族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32138660.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的处理信息：将1只爬虫类族怪兽从卡组加入手卡（供连锁判定等使用）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只爬虫类族怪兽加入持有者手卡，并向对方展示。
function c32138660.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选出1张符合条件的爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c32138660.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
