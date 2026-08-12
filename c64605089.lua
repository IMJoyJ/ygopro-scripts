--護封剣の剣士
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，特殊召唤的这张卡的守备力比那只攻击怪兽的攻击力高的场合，那只攻击怪兽破坏。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡1回合只有1次不会被战斗破坏。
function c64605089.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，特殊召唤的这张卡的守备力比那只攻击怪兽的攻击力高的场合，那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64605089,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c64605089.condition)
	e1:SetTarget(c64605089.target)
	e1:SetOperation(c64605089.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c64605089.efcon)
	e2:SetOperation(c64605089.efop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c64605089.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方控制，且没有攻击对象（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果①的发动准备与合法性检查函数
function c64605089.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，准备将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 检查攻击怪兽的攻击力是否低于这张卡的守备力
	if Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense() then
		-- 设置破坏的操作信息，准备破坏攻击怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
	end
end
-- 效果①的处理函数，执行特殊召唤及后续的破坏处理
function c64605089.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤，并检查是否成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and at:IsFaceup() and at:IsRelateToBattle() and at:GetAttack()<c:GetDefense() then
		-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 将该攻击怪兽因效果破坏
		Duel.Destroy(at,REASON_EFFECT)
	end
end
-- 效果②的触发条件判定：作为超量召唤素材且原本在场上存在
function c64605089.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的处理：为超量召唤出的怪兽赋予抗性效果，并在必要时使其成为效果怪兽
function c64605089.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(64605089,1))  --"「护封剑之剑士」效果适用中"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c64605089.valcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 抗性适用条件判定：仅在因战斗破坏时适用
function c64605089.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
