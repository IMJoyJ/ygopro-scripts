--光と闇の竜
-- 效果：
-- 这张卡不能特殊召唤。这张卡的属性也当作「暗」使用。只要这张卡在场上表侧表示存在，效果怪兽的效果·魔法·陷阱卡的发动无效。每次这个效果把卡的发动无效，这张卡的攻击力·守备力下降500。这张卡被破坏送去墓地时，选择自己墓地存在的1只怪兽发动。自己场上的卡全部破坏。选择的1只怪兽在自己场上特殊召唤。
function c47297616.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设置为恒为假，使得这张卡无法通过任何方式特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡的属性也当作「暗」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，效果怪兽的效果·魔法·陷阱卡的发动无效。
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
	-- 这张卡被破坏送去墓地时，选择自己墓地存在的1只怪兽发动。自己场上的卡全部破坏。选择的1只怪兽在自己场上特殊召唤。
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
-- 判断被连锁的效果是否为魔法·陷阱卡的发动或效果怪兽的效果，且光与暗之龙本身不在连锁处理中，满足这些条件时才能发动无效效果。
function c47297616.codisable(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
		and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
-- 无效效果的发动判定：本回合尚未使用过该次无效效果；若光与暗之龙受天邪鬼影响，则打上标记以在后续倒置攻守变化；最后登记要使连锁中的那张卡发动无效。
function c47297616.tgdisable(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(47297616)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(47297616,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 登记本次操作信息：将连锁中正在发动的卡（eg）标记为要被无效的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效处理前进行各种检查：光与暗之龙不在里侧、攻击力守备力充足、效果仍关联、连锁序号正确且未被战斗破坏，否则不发动。
function c47297616.opdisable(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:GetDefense()<500 or c:GetAttack()<500 or not c:IsRelateToEffect(e)
		-- 若当前连锁序号不是被无效连锁的下一连锁，或光与暗之龙处于战斗破坏状态，则不进行发动无效。
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 尝试使目标连锁的卡发动无效，若成功则继续执行攻击力·守备力下降500的效果。
	if Duel.NegateActivation(ev) then
		-- 每次这个效果把卡的发动无效，这张卡的攻击力·守备力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
		-- 每次这个效果把卡的发动无效，这张卡的攻击力·守备力下降500。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-500)
		c:RegisterEffect(e2)
	end
end
-- 判断光与暗之龙是否因被破坏而送去墓地，满足时才能发动墓地遗言效果。
function c47297616.cdspsum(e)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 检查选择的对象必须是自己墓地的怪兽，并且能够被自己表侧表示特殊召唤，才能作为效果对象。
function c47297616.tgspsum(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp) end
	if chk==0 then return true end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合特殊召唤条件的怪兽作为效果对象，并将该卡设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,1,1,nil,e,0,tp,false,false,POS_FACEUP,tp)
	-- 登记操作信息：将选择的对象怪兽进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 取得自己场上所有卡（包含光与暗之龙自身），作为将要被破坏的候选集合。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 登记操作信息：将自己场上的全部卡（dg）破坏，数量为dg的张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理时先破坏自己场上所有卡；若选中的怪兽仍与效果关联，则中断效果处理，将那只怪兽特殊召唤到自己场上。
function c47297616.opspsum(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新取得自己场上所有卡（不分表侧里侧）作为破坏对象。
	local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
	-- 以效果破坏这些卡并将其送去墓地。
	Duel.Destroy(dg,REASON_EFFECT)
	-- 取得发动时选择的那1只墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 中断当前效果处理，使破坏与特殊召唤变成不同时处理，避免错过特殊召唤成功的时点。
		Duel.BreakEffect()
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
