--ディープアイズ・ホワイト・ドラゴン
-- 效果：
-- ①：自己场上的表侧表示的「青眼」怪兽被战斗或者对方的效果破坏时才能发动。这张卡从手卡特殊召唤，给与对方为自己墓地的龙族怪兽种类×600伤害。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只龙族怪兽为对象发动。这张卡的攻击力变成和那只怪兽的攻击力相同。
-- ③：场上的这张卡被效果破坏的场合发动。对方场上的怪兽全部破坏。
function c22804410.initial_effect(c)
	-- ①：自己场上的表侧表示的「青眼」怪兽被战斗或者对方的效果破坏时才能发动。这张卡从手卡特殊召唤，给与对方为自己墓地的龙族怪兽种类×600伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22804410,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c22804410.spcon)
	e1:SetTarget(c22804410.sptg)
	e1:SetOperation(c22804410.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只龙族怪兽为对象发动。这张卡的攻击力变成和那只怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22804410,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c22804410.atktg)
	e2:SetOperation(c22804410.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被效果破坏的场合发动。对方场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c22804410.descon)
	e4:SetTarget(c22804410.destg)
	e4:SetOperation(c22804410.desop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断被破坏的怪兽是否为「青眼」怪兽且为表侧表示，且破坏原因来自战斗或对方效果。
function c22804410.spfilter(c,tp)
	return c:IsPreviousSetCard(0xdd) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断是否有满足spfilter条件的怪兽被破坏，用于触发效果。
function c22804410.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22804410.spfilter,1,nil,tp)
end
-- 设置特殊召唤和伤害的处理条件，包括场上是否有空位、手牌是否可特殊召唤、墓地是否有龙族怪兽。
function c22804410.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位，用于判断是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否有龙族怪兽，用于计算伤害值。
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_DRAGON) end
	-- 获取墓地所有龙族怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_DRAGON)
	local dam=g:GetClassCount(Card.GetCode)*600
	-- 设置特殊召唤的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置造成伤害的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行特殊召唤操作，若成功则计算并造成伤害。
function c22804410.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，若成功则继续处理后续效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取墓地所有龙族怪兽的集合。
		local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_DRAGON)
		local dam=g:GetClassCount(Card.GetCode)*600
		-- 对对方造成伤害，伤害值为龙族怪兽数量乘以600。
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
-- 设置选择目标的处理流程，选择墓地的龙族怪兽作为攻击力来源。
function c22804410.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsRace(RACE_DRAGON) end
	if chk==0 then return true end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地的一只龙族怪兽作为目标。
	Duel.SelectTarget(tp,Card.IsRace,tp,LOCATION_GRAVE,0,1,1,nil,RACE_DRAGON)
end
-- 执行攻击力变更操作，将该卡攻击力设为所选怪兽的攻击力。
function c22804410.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local atk=tc:GetAttack()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置该卡的攻击力为指定值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否因效果破坏且在场上被破坏。
function c22804410.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置破坏对方场上所有怪兽的处理条件。
function c22804410.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有怪兽的集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏对方场上所有怪兽的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏对方场上所有怪兽的操作。
function c22804410.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有怪兽的集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏对方场上所有怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
