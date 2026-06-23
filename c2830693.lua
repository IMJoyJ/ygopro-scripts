--虹クリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽不能攻击。
-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c2830693.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2830693,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2830693)
	e1:SetTarget(c2830693.eqtg)
	e1:SetOperation(c2830693.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2830693,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2830694)
	e2:SetCondition(c2830693.spcon)
	e2:SetTarget(c2830693.sptg)
	e2:SetOperation(c2830693.spop)
	c:RegisterEffect(e2)
end
-- 检查是否满足装备效果的发动条件
function c2830693.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	-- 判断场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and at:IsControler(1-tp) and at:IsRelateToBattle() and at:IsCanBeEffectTarget(e) end
	-- 设置装备效果的目标怪兽
	Duel.SetTargetCard(at)
end
-- 执行装备效果的操作
function c2830693.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否满足装备条件（场地不足、目标怪兽里侧、目标怪兽无效）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	else
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制效果
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c2830693.eqlimit)
		c:RegisterEffect(e1)
		-- 设置装备卡无法攻击的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备对象限制函数
function c2830693.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断是否满足特殊召唤条件
function c2830693.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为对方控制且未攻击其他怪兽
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 检查是否满足特殊召唤的发动条件
function c2830693.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function c2830693.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断特殊召唤是否成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置特殊召唤后离场时的去向为除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
