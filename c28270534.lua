--キ－Ai－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己场上的攻击力2300以上的「@火灵天星」怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
-- ③：这张卡被除外的场合才能发动。这个回合，自己的攻击力2300以上的「@火灵天星」怪兽不会被战斗破坏。
function c28270534.initial_effect(c)
	-- ①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 过滤满足条件的「@火灵天星」怪兽（可特殊召唤）
function c28270534.filter(c,e,tp)
	return c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足效果发动条件（是否有可特殊召唤的墓地怪兽）
function c28270534.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28270534.filter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c28270534.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c28270534.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息（特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理（特殊召唤目标怪兽）
function c28270534.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为满足条件的场上「@火灵天星」怪兽（攻击力2300以上）
function c28270534.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsAttackAbove(2300)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件（是否能除外自身并有符合条件的怪兽被破坏）
function c28270534.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c28270534.repfilter,1,nil,tp) end
	-- 询问玩家是否发动效果（代替破坏）
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回代替破坏的判断条件
function c28270534.repval(e,c)
	return c28270534.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏（将自身除外）
function c28270534.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- 注册战斗破坏不可破坏效果
function c28270534.indesop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册战斗破坏不可破坏效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c28270534.indestg)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为满足条件的场上「@火灵天星」怪兽（攻击力2300以上）
function c28270534.indestg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsAttackAbove(2300)
end
