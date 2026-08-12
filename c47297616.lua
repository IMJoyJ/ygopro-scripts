--光と闇の竜
-- 效果：
-- 这张卡不能特殊召唤。这张卡的属性也当作「暗」使用。只要这张卡在场上表侧表示存在，效果怪兽的效果·魔法·陷阱卡的发动无效。每次这个效果把卡的发动无效，这张卡的攻击力·守备力下降500。这张卡被破坏送去墓地时，选择自己墓地存在的1只怪兽发动。自己场上的卡全部破坏。选择的1只怪兽在自己场上特殊召唤。
function c47297616.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡的属性也当作「暗」使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	-- 诱发即时必发效果，对应二速的【效果发动无效】
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47297616,2))  --"效果发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c47297616.codisable)
	e3:SetTarget(c47297616.tgdisable)
	e3:SetOperation(c47297616.opdisable)
	c:RegisterEffect(e3)
	-- 这张卡被破坏送去墓地时，选择自己墓地存在的1只怪兽发动。自己场上的卡全部破坏。选择的1只怪兽在自己场上特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47297616,4))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c47297616.cdspsum)
	e4:SetTarget(c47297616.tgspsum)
	e4:SetOperation(c47297616.opspsum)
	c:RegisterEffect(e4)
end
-- 效果发动时，判断是否为魔法或怪兽效果发动且该卡未在连锁中
function c47297616.codisable(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
		and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
-- 设置连锁处理时的提示信息，表示将使发动无效
function c47297616.tgdisable(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(47297616)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(47297616,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 处理效果发动无效的条件判断
function c47297616.opdisable(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:GetDefense()<500 or c:GetAttack()<500 or not c:IsRelateToEffect(e)
		-- 判断当前连锁是否为该效果所触发的连锁
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 使该连锁发动无效
	if Duel.NegateActivation(ev) then
		-- 使该卡攻击力下降500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
		-- 使该卡守备力下降500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-500)
		c:RegisterEffect(e2)
	end
end
-- 判断该卡被破坏送去墓地时触发
function c47297616.cdspsum(e)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 设置选择目标为己方墓地可特殊召唤的怪兽
function c47297616.tgspsum(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,1,1,nil,e,0,tp,false,false,POS_FACEUP,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 获取场上所有己方卡牌
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 设置操作信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 处理墓地效果，破坏场上卡并特殊召唤选中的怪兽
function c47297616.opspsum(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有己方卡牌
	local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
	-- 将场上所有己方卡牌破坏
	Duel.Destroy(dg,REASON_EFFECT)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
