--機巧辰－高闇御津羽靇
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上有2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：支付1500基本分才能发动。从额外卡组特殊召唤的场上的怪兽全部破坏。这个回合，自己只能用1只怪兽攻击。
-- ③：这张卡被对方送去墓地的场合才能发动。选对方墓地1只怪兽除外。那之后，自己基本分回复那个攻击力的数值。
function c43218406.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在场上有2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43218406)
	e1:SetCondition(c43218406.spcon)
	e1:SetTarget(c43218406.sptg)
	e1:SetOperation(c43218406.spop)
	c:RegisterEffect(e1)
	-- ②：支付1500基本分才能发动。从额外卡组特殊召唤的场上的怪兽全部破坏。这个回合，自己只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43218406,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43218406.descost)
	e2:SetTarget(c43218406.destg)
	e2:SetOperation(c43218406.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方送去墓地的场合才能发动。选对方墓地1只怪兽除外。那之后，自己基本分回复那个攻击力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43218406,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,43218407)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c43218406.recon)
	e3:SetTarget(c43218406.retg)
	e3:SetOperation(c43218406.reop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断怪兽是否从额外卡组召唤
function c43218406.spfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果条件函数，检查场上是否有至少2只从额外卡组特殊召唤的怪兽
function c43218406.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少2只从额外卡组特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(c43218406.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
-- 设置特殊召唤的处理目标
function c43218406.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c43218406.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 支付LP的处理函数
function c43218406.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 过滤函数，用于判断怪兽是否从额外卡组召唤
function c43218406.desfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 设置破坏效果的处理目标
function c43218406.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只从额外卡组特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c43218406.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c43218406.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的处理函数
function c43218406.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c43218406.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 执行破坏操作
	Duel.Destroy(sg,REASON_EFFECT)
	local c=e:GetHandler()
	-- ②：支付1500基本分才能发动。从额外卡组特殊召唤的场上的怪兽全部破坏。这个回合，自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c43218406.checkop)
	-- 注册攻击宣告时的持续效果
	Duel.RegisterEffect(e1,tp)
	-- ②：支付1500基本分才能发动。从额外卡组特殊召唤的场上的怪兽全部破坏。这个回合，自己只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c43218406.atkcon)
	e2:SetTarget(c43218406.atktg)
	e1:SetLabelObject(e2)
	-- 注册不能攻击宣告的效果
	Duel.RegisterEffect(e2,tp)
end
-- 攻击宣告时的处理函数
function c43218406.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已注册标识效果
	if Duel.GetFlagEffect(tp,43218406)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 注册标识效果
	Duel.RegisterFlagEffect(tp,43218406,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 判断是否已注册标识效果
function c43218406.atkcon(e)
	-- 判断是否已注册标识效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),43218406)>0
end
-- 设置不能攻击的目标
function c43218406.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- ③：这张卡被对方送去墓地的场合才能发动。选对方墓地1只怪兽除外。那之后，自己基本分回复那个攻击力的数值。
function c43218406.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤函数，用于判断墓地中的怪兽是否可以除外
function c43218406.filter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 设置除外并回复LP效果的处理目标
function c43218406.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c43218406.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置除外效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
	-- 设置回复LP效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 除外并回复LP效果的处理函数
function c43218406.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1只怪兽除外
	local tc=Duel.SelectMatchingCard(tp,c43218406.filter,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()
	if not tc then return end
	local atk=tc:GetTextAttack()
	-- 判断是否成功除外并攻击力大于0
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and atk>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 回复LP
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
