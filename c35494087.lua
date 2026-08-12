--SRビードロ・ドクロ
-- 效果：
-- 「疾行机人 噗噗噔骷髅」的③的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段，从额外卡组特殊召唤的怪兽在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡不会被和通常召唤的怪兽的战斗破坏。
-- ③：这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ④：自己场上有「疾行机人」怪兽以外的表侧表示怪兽存在的场合这张卡破坏。
function c35494087.initial_effect(c)
	-- ①：自己·对方的准备阶段，从额外卡组特殊召唤的怪兽在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35494087,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c35494087.spcon)
	e1:SetTarget(c35494087.sptg)
	e1:SetOperation(c35494087.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和通常召唤的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c35494087.indval)
	c:RegisterEffect(e2)
	-- ③：这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetValue(c35494087.refval)
	c:RegisterEffect(e3)
	-- ④：自己场上有「疾行机人」怪兽以外的表侧表示怪兽存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c35494087.sdcon)
	c:RegisterEffect(e4)
end
-- 检查在对方场上是否存在从额外卡组特殊召唤的怪兽
function c35494087.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件则返回true
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
-- 设置特殊召唤的处理目标
function c35494087.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c35494087.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断目标怪兽是否为通常召唤
function c35494087.indval(e,c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 处理效果使用次数的逻辑，确保③的效果1回合只能使用1次
function c35494087.refval(e,c)
	if e:GetHandler():GetFlagEffect(35494087)~=0 then
		-- 注册一个标记效果，用于记录该效果已在本回合使用过
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(),35494087,RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():ResetFlagEffect(35494087)
		return true
	-- 若未使用过该效果，则注册标记
	elseif Duel.GetFlagEffect(e:GetHandlerPlayer(),35494087)==0 then
		e:GetHandler():RegisterFlagEffect(35494087,0,0,1)
		return true
	else return false end
end
-- 过滤函数，用于筛选场上的非「疾行机人」怪兽
function c35494087.sdfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x2016)
end
-- 判断场上的怪兽数量是否满足破坏条件
function c35494087.sdcon(e)
	-- 满足条件则返回true
	return Duel.IsExistingMatchingCard(c35494087.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
