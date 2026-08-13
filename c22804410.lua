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
-- 过滤器：判定被破坏的怪兽是否曾是己方场上表侧表示的「青眼」怪兽，且破坏原因是战斗或对方发动的效果。
function c22804410.spfilter(c,tp)
	return c:IsPreviousSetCard(0xdd) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 诱发条件：本次被破坏的怪兽集合中存在至少1只满足spfilter条件的「青眼」怪兽。
function c22804410.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22804410.spfilter,1,nil,tp)
end
-- 发动条件判定：己方场上有空余怪兽区、此卡可以从手牌特殊召唤、且自己墓地有至少1只龙族怪兽时，效果才能发动。
function c22804410.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上的主要怪兽区是否有空位，用于判断能否特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在至少1只龙族怪兽，作为发动条件和伤害计算的基础。
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_DRAGON) end
	-- 获取自己墓地的全部龙族怪兽，用于统计种类数。
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_DRAGON)
	local dam=g:GetClassCount(Card.GetCode)*600
	-- 设置操作信息：本次效果包含将渊眼白龙从手卡特殊召唤，对象为效果持有者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果包含给与对方伤害，伤害数值为dam（龙族种类数×600），对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：若此卡仍与效果相关，则将其从手卡表侧表示特殊召唤；若特殊召唤成功，则重新统计自己墓地的龙族种类，并给对方造成种类数×600伤害。
function c22804410.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将渊眼白龙以表侧表示特殊召唤到己方场上；若特殊召唤成功（返回值不为0），则继续执行伤害。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤成功后，重新获取自己墓地的龙族怪兽，以计算当前的种类数。
		local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_DRAGON)
		local dam=g:GetClassCount(Card.GetCode)*600
		-- 给对方造成dam点效果伤害，dam等于自己墓地的龙族怪兽种类数×600。
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
-- ②效果的发动与取对象处理：以自己墓地1只龙族怪兽为对象；先校验对象合法性，再提示玩家选择并设定为效果对象。
function c22804410.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsRace(RACE_DRAGON) end
	if chk==0 then return true end
	-- 向操作玩家显示选择对象的提示，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让己方玩家从自己墓地选择1只龙族怪兽，将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsRace,tp,LOCATION_GRAVE,0,1,1,nil,RACE_DRAGON)
end
-- 效果处理：取得对象怪兽；若对象与渊眼白龙均有效，则将渊眼白龙的攻击力变为对象怪兽的攻击力。
function c22804410.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的第一张对象卡，即作为攻击力参照的墓地龙族怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local atk=tc:GetAttack()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力变成和那只怪兽的攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③效果诱发条件：渊眼白龙在场上被效果破坏（而非战斗破坏），即破坏原因包含效果且破坏前位于场上。
function c22804410.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果发动时的条件处理：无特殊发动条件；获取对方场上的全部怪兽，并设置破坏的操作信息（数量为对方怪兽数）。
function c22804410.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的全部怪兽（不取对象，选择对方怪兽区的所有怪兽）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：预定将对方场上的全部怪兽破坏，破坏分类为效果破坏，数量为当前对方怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：实际将对方场上的全部怪兽以效果破坏。
function c22804410.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方场上的全部怪兽，以实际场上状态为准。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏获取到的对方场上的全部怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
