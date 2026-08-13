--キ－Ai－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己场上的攻击力2300以上的「@火灵天星」怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
-- ③：这张卡被除外的场合才能发动。这个回合，自己的攻击力2300以上的「@火灵天星」怪兽不会被战斗破坏。
function c28270534.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28270534+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28270534.target)
	e1:SetOperation(c28270534.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的攻击力2300以上的「@火灵天星」怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c28270534.reptg)
	e2:SetValue(c28270534.repval)
	e2:SetOperation(c28270534.repop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合才能发动。这个回合，自己的攻击力2300以上的「@火灵天星」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28270534,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetOperation(c28270534.indesop)
	c:RegisterEffect(e3)
end
-- 判断候选怪兽是否属于「@火灵天星」系列，且能够被当前效果特殊召唤。
function c28270534.filter(c,e,tp)
	return c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件与取对象判定：以自己墓地1只「@火灵天星」怪兽为对象，且自己场上有可用的怪兽区；若已选对象则校验该对象是否符合条件。
function c28270534.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28270534.filter(chkc,e,tp) end
	-- 确认自己场上是否有空余的怪兽区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地中存在至少1只满足特殊召唤条件的「@火灵天星」怪兽。
		and Duel.IsExistingTarget(c28270534.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给予玩家“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「@火灵天星」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c28270534.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁要进行的特殊召唤操作信息登记，指定对象为该怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：若对象怪兽仍与效果关联，则将其特殊召唤。
function c28270534.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时需要特殊召唤的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定被破坏的怪兽是否满足代替破坏条件：自己场上的表侧表示「@火灵天星」怪兽、攻击力2300以上、在主要怪兽区、因效果被破坏且不是由代替破坏产生。
function c28270534.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsAttackAbove(2300)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判定代替破坏效果是否可用：这张卡在墓地可除外，且本次破坏的怪兽中存在满足条件的「@火灵天星」怪兽，同时让玩家选择是否发动。
function c28270534.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c28270534.repfilter,1,nil,tp) end
	-- 询问玩家是否发动这张卡的代替破坏效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的判定函数：对被破坏的怪兽套用过滤条件，确认其是否符合代替破坏对象。
function c28270534.repval(e,c)
	return c28270534.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果处理：将墓地的这张卡除外，以代替符合条件的怪兽被效果破坏。
function c28270534.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡以表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- ③效果发动后的处理：创建一个保护效果，使这个回合内自己的攻击力2300以上的「@火灵天星」怪兽不会被战斗破坏。
function c28270534.indesop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己的攻击力2300以上的「@火灵天星」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c28270534.indestg)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该“不会被战斗破坏”的持续效果注册到决斗中，使其作用于己方符合条件的怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 判定怪兽是否为自己场上的表侧表示且属于「@火灵天星」、攻击力2300以上。
function c28270534.indestg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsAttackAbove(2300)
end
