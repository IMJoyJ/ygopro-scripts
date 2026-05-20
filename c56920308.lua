--強靭！無敵！最強！
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只「青眼」怪兽为对象才能发动。这个回合，那只表侧表示怪兽不会被战斗破坏，不受自身以外的卡的效果影响，和那只怪兽进行战斗的怪兽在伤害步骤结束时破坏。
-- ②：这张卡在墓地存在的状态，自己把「青眼白龙」召唤·特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c56920308.initial_effect(c)
	-- 记录这张卡记载了「青眼白龙」的卡名。
	aux.AddCodeList(c,89631139)
	-- ①：以自己场上1只「青眼」怪兽为对象才能发动。这个回合，那只表侧表示怪兽不会被战斗破坏，不受自身以外的卡的效果影响，和那只怪兽进行战斗的怪兽在伤害步骤结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c56920308.target)
	e1:SetOperation(c56920308.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己把「青眼白龙」召唤·特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56920308,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,56920308)
	e2:SetCondition(c56920308.setcon)
	e2:SetTarget(c56920308.settg)
	e2:SetOperation(c56920308.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤出自己场上表侧表示的「青眼」怪兽。
function c56920308.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdd)
end
-- ①号效果的发动准备与对象选择。
function c56920308.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c56920308.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「青眼」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c56920308.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「青眼」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c56920308.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①号效果的发动处理，为目标怪兽赋予抗性、战破免疫以及战后破坏对手怪兽的效果。
function c56920308.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 不受自身以外的卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c56920308.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，那只表侧表示怪兽不会被战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 和那只怪兽进行战斗的怪兽在伤害步骤结束时破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetCondition(c56920308.descon)
		e3:SetOperation(c56920308.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 免疫除这张卡（强韧！无敌！最强！）以外的卡的效果。
function c56920308.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
-- 检查与该怪兽进行战斗的对手怪兽在伤害步骤结束时是否仍存在于战斗中。
function c56920308.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsRelateToBattle()
end
-- 破坏与该怪兽进行战斗的对手怪兽。
function c56920308.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 提示发动了「强韧！无敌！最强！」的效果。
	Duel.Hint(HINT_CARD,0,56920308)
	-- 因效果破坏进行战斗的对手怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 过滤出自己召唤·特殊召唤的「青眼白龙」。
function c56920308.cfilter(c,tp)
	return c:IsCode(89631139) and c:IsSummonPlayer(tp)
end
-- 检查自己是否召唤·特殊召唤了「青眼白龙」。
function c56920308.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56920308.cfilter,1,nil,tp)
end
-- ②号效果的发动准备，确认自身是否可以盖放并设置操作信息。
function c56920308.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息为将墓地的这张卡移出墓地（盖放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的发动处理，将这张卡在场上盖放，并添加离场除外的约束。
function c56920308.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍存在于墓地，并将其在自己场上盖放。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
