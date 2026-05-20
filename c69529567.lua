--おとぼけオポッサム
-- 效果：
-- 自己的主要阶段时，持有比这张卡的攻击力高的攻击力的怪兽在对方场上表侧表示存在的场合，可以把场上存在的这张卡破坏。此外，自己的准备阶段时，这张卡的效果破坏的这张卡可以从墓地特殊召唤。
function c69529567.initial_effect(c)
	-- 自己的主要阶段时，持有比这张卡的攻击力高的攻击力的怪兽在对方场上表侧表示存在的场合，可以把场上存在的这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69529567,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c69529567.descon)
	e1:SetTarget(c69529567.destg)
	e1:SetOperation(c69529567.desop)
	c:RegisterEffect(e1)
	-- 此外，自己的准备阶段时，这张卡的效果破坏的这张卡可以从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69529567,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c69529567.spcon)
	e2:SetTarget(c69529567.sptg)
	e2:SetOperation(c69529567.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选对方场上表侧表示且攻击力高于此卡的怪兽
function c69529567.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 破坏效果的发动条件：自己的主要阶段，且对方场上存在攻击力高于此卡的表侧表示怪兽
function c69529567.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力高于此卡的怪兽
	return Duel.IsExistingMatchingCard(c69529567.desfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
-- 破坏效果的靶向与合法性检测：确认自身在场，并声明破坏自身的操作信息
function c69529567.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_ONFIELD) end
	-- 向系统宣告：此效果的处理包含将自身破坏的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的执行：将自身破坏，若成功则为自身注册一个重置前有效的标记，以记录是被自身效果破坏
function c69529567.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则通过效果将其破坏；破坏成功时，为自身注册一个在离场等情况下重置的标记，用于记录是被自身效果破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		e:GetHandler():RegisterFlagEffect(69529567,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 特殊召唤效果的发动条件：自己的准备阶段
function c69529567.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤效果的靶向与合法性检测：确认自身带有被自身效果破坏的标记，并声明特殊召唤自身的操作信息
function c69529567.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(69529567)~=0 end
	-- 向系统宣告：此效果的处理包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将自身特殊召唤
function c69529567.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
