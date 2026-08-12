--ゴーストリック・イエティ
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转时，以场上1只「鬼计」怪兽为对象才能发动。那只怪兽在这个回合不会被战斗·效果破坏。
function c84472026.initial_effect(c)
	-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c84472026.sumcon)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84472026,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c84472026.postg)
	e2:SetOperation(c84472026.posop)
	c:RegisterEffect(e2)
	-- ②：这张卡反转时，以场上1只「鬼计」怪兽为对象才能发动。那只怪兽在这个回合不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84472026,1))  --"破坏耐性"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FLIP)
	e3:SetTarget(c84472026.indestg)
	e3:SetOperation(c84472026.indesop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「鬼计」怪兽
function c84472026.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的条件：自己场上不存在表侧表示的「鬼计」怪兽
function c84472026.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c84472026.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①号效果（变成里侧守备表示）的发动准备与合法性检测，并给自身注册一回合一次的Flag
function c84472026.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(84472026)==0 end
	c:RegisterFlagEffect(84472026,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁处理中的操作信息：改变1张卡（自身）的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①号效果（变成里侧守备表示）的效果处理：若自身仍表侧表示存在则将其转为里侧守备表示
function c84472026.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- ②号效果（反转时获得破坏耐性）的发动准备：检测并选择场上1只表侧表示的「鬼计」怪兽作为对象
function c84472026.indestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c84472026.sfilter(chkc) end
	-- 在发动阶段检测场上是否存在可以作为对象的表侧表示「鬼计」怪兽
	if chk==0 then return Duel.IsExistingTarget(c84472026.sfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「鬼计」怪兽作为效果对象
	Duel.SelectTarget(tp,c84472026.sfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②号效果（反转时获得破坏耐性）的效果处理：使选择的对象怪兽在本回合内不会被战斗和效果破坏
function c84472026.indesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 不会被战斗·效果破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
