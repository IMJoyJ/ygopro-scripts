--教導の神徒
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：融合·同调·超量·连接怪兽被送去自己或者对方的墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合，以「教导的神徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
-- ③：对方怪兽的攻击宣言时才能发动。自己场上的全部「教导」怪兽的攻击力上升500。
function c13694209.initial_effect(c)
	-- ①：融合·同调·超量·连接怪兽被送去自己或者对方的墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13694209,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13694209)
	e1:SetCondition(c13694209.spcon)
	e1:SetTarget(c13694209.sptg)
	e1:SetOperation(c13694209.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合，以「教导的神徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13694209,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,13694210)
	e2:SetCondition(c13694209.thcon)
	e2:SetTarget(c13694209.thtg)
	e2:SetOperation(c13694209.thop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽的攻击宣言时才能发动。自己场上的全部「教导」怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13694209,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13694211)
	e3:SetCondition(c13694209.atkcon)
	e3:SetTarget(c13694209.atktg)
	e3:SetOperation(c13694209.atkop)
	c:RegisterEffect(e3)
end
-- 检查本次送去墓地的怪兽中是否存在至少1只融合·同调·超量或连接怪兽，作为①效果的发动条件。
function c13694209.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- ①效果发动时的目标检查和操作信息设定：确认自己主要怪兽区有空位且此卡能被特殊召唤，并登记特殊召唤操作。
function c13694209.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己场上是否有可用怪兽区域，且这张卡是否满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将这张卡特殊召唤的操作信息登记到当前连锁中，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c13694209.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：判断此卡是从手牌特殊召唤成功的。
function c13694209.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 筛选可以加入手卡的墓地「教导」卡：卡名含「教导」、不是“教导的神徒”本身、且能被加入手卡。
function c13694209.thfilter(c)
	return c:IsSetCard(0x145) and not c:IsCode(13694209) and c:IsAbleToHand()
end
-- ②效果发动时选择自己墓地1张符合条件的「教导」卡为对象，并登记加入手卡的操作信息。
function c13694209.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13694209.thfilter(chkc) end
	-- 效果发动时检查自己墓地是否存在至少1张符合条件的「教导」卡。
	if chk==0 then return Duel.IsExistingTarget(c13694209.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「教导」卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,c13694209.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的对象卡加入手卡的操作信息登记到当前连锁中。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若对象卡仍与效果关联，则将其加入持有者手卡。
function c13694209.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③效果的发动条件：确认攻击宣言的怪兽是对方控制的怪兽。
function c13694209.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前发动攻击宣言的怪兽的控制者是否为对方玩家。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 筛选自己场上表侧表示且卡名含「教导」的怪兽。
function c13694209.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145)
end
-- ③效果发动时检查自己场上是否存在至少1只表侧表示的「教导」怪兽。
function c13694209.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己场上有符合条件的「教导」怪兽才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13694209.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ③效果处理：为自己场上所有表侧表示的「教导」怪兽各附加一个攻击力上升500的效果。
function c13694209.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示的「教导」怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c13694209.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「教导」怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
