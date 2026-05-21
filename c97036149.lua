--天威龍－ナハタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：效果怪兽以外的自己的表侧表示怪兽在和对方的表侧表示怪兽进行战斗的攻击宣言时，把手卡·墓地的这张卡除外才能发动。那只对方怪兽的攻击力直到回合结束时下降1500。
function c97036149.initial_effect(c)
	-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97036149,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,97036149)
	e1:SetCondition(c97036149.spcon)
	e1:SetTarget(c97036149.sptg)
	e1:SetOperation(c97036149.spop)
	c:RegisterEffect(e1)
	-- ②：效果怪兽以外的自己的表侧表示怪兽在和对方的表侧表示怪兽进行战斗的攻击宣言时，把手卡·墓地的这张卡除外才能发动。那只对方怪兽的攻击力直到回合结束时下降1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97036149,1))  --"对方怪兽攻击力下降"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,97036150)
	e2:SetCondition(c97036149.atkcon)
	-- 把手卡·墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c97036149.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的效果怪兽
function c97036149.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 特殊召唤效果的发动条件：自己场上没有表侧表示的效果怪兽存在
function c97036149.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的效果怪兽，若不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(c97036149.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位以及自身是否可以特殊召唤
function c97036149.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理：若自身仍在手卡，则将自身特殊召唤
function c97036149.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力下降效果的发动条件：效果怪兽以外的自己的表侧表示怪兽与对方的表侧表示怪兽进行战斗的攻击宣言时
function c97036149.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(d)
	return not a:IsType(TYPE_EFFECT) and d:IsControler(1-tp)
		and d:IsFaceup() and a:IsFaceup()
end
-- 攻击力下降效果的实际处理：使进行战斗的对方怪兽的攻击力直到回合结束时下降1500
function c97036149.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToBattle() then return end
	-- 那只对方怪兽的攻击力直到回合结束时下降1500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1500)
	tc:RegisterEffect(e1)
end
