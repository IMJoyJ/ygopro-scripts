--BK グラスジョー
-- 效果：
-- ①：这张卡被选择作为攻击对象的场合发动。这张卡破坏。
-- ②：这张卡被效果送去墓地时，以「燃烧拳击手 不堪一击拳手」以外的自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽加入手卡。
function c5361647.initial_effect(c)
	-- ①：这张卡被选择作为攻击对象的场合发动。这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5361647,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c5361647.destg)
	e1:SetOperation(c5361647.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地时，以「燃烧拳击手 不堪一击拳手」以外的自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5361647,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c5361647.thcon)
	e2:SetTarget(c5361647.thtg)
	e2:SetOperation(c5361647.thop)
	c:RegisterEffect(e2)
end
-- 效果发动时的目标函数：发动条件无需额外判定，直接返回true，并设置破坏这张卡的操作信息。
function c5361647.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的处理信息为破坏这张卡，供相关效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时的操作函数：若这张卡仍与效果相关联，则将其破坏。
function c5361647.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因破坏这张卡。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 诱发条件：判定这张卡被送去墓地的原因是否为效果。
function c5361647.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选条件：自己墓地中满足「燃烧拳击手」字段、卡名不是「燃烧拳击手 不堪一击拳手」的怪兽卡，且能够被加入手卡。
function c5361647.filter(c)
	return c:IsSetCard(0x1084) and not c:IsCode(5361647) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 选发效果的发动与目标选择函数：检查是否有符合条件的对象，提示玩家选择，选定对象并设置回手牌操作信息。
function c5361647.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c5361647.filter(chkc) end
	-- 发动时确认自己墓地是否存在至少1张符合条件的「燃烧拳击手」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c5361647.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1张符合条件的「燃烧拳击手」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c5361647.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的处理信息为将选中的对象加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的操作函数：取得对象，若仍与效果关联则将其加入手卡，并向对方展示。
function c5361647.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中本次效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
