--WW－スノウ・ベル
-- 效果：
-- ①：自己场上有风属性怪兽2只以上存在，没有风属性以外的怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：用这张卡为同调素材把风属性同调怪兽同调召唤的场合，那只同调怪兽不会被对方的效果破坏。
function c70117860.initial_effect(c)
	-- ①：自己场上有风属性怪兽2只以上存在，没有风属性以外的怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70117860,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c70117860.spcon)
	e1:SetTarget(c70117860.sptg)
	e1:SetOperation(c70117860.spop)
	c:RegisterEffect(e1)
	-- ②：用这张卡为同调素材把风属性同调怪兽同调召唤的场合，那只同调怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c70117860.efcon)
	e2:SetOperation(c70117860.efop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的风属性怪兽
function c70117860.cfilter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤条件：里侧表示怪兽或风属性以外的怪兽
function c70117860.cfilter2(c)
	return c:IsFacedown() or c:IsNonAttribute(ATTRIBUTE_WIND)
end
-- 特殊召唤效果的发动条件：自己场上有2只以上风属性怪兽，且不存在风属性以外的怪兽
function c70117860.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的风属性怪兽
	return Duel.IsExistingMatchingCard(c70117860.cfilter1,tp,LOCATION_MZONE,0,2,nil)
		-- 且检查自己场上不存在里侧表示怪兽或风属性以外的怪兽
		and not Duel.IsExistingMatchingCard(c70117860.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶向/发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c70117860.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段（chk==0），检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息：将自身特殊召唤（数量为1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身从手卡特殊召唤
function c70117860.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果授予的条件：作为同调素材且同调召唤的怪兽是风属性
function c70117860.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- 效果授予的处理：给该同调怪兽注册“不会被对方的效果破坏”的效果
function c70117860.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 那只同调怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70117860,1))  --"「风魔女-雪铃」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(ep)
	e1:SetValue(c70117860.tgval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 抗性值函数：限制破坏效果的来源必须是对方玩家
function c70117860.tgval(e,re,rp)
	return rp==1-e:GetLabel()
end
