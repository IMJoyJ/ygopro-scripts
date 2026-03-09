--BF－流離いのコガラシ
-- 效果：
-- 自己场上表侧表示存在的名字带有「黑羽」的怪兽被卡的效果破坏送去墓地时，这张卡可以从手卡特殊召唤。此外，这张卡为同调素材的同调召唤成功时，对方不能把魔法·陷阱·效果怪兽的效果发动。
function c49460512.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「黑羽」的怪兽被卡的效果破坏送去墓地时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49460512,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49460512.spcon)
	e1:SetTarget(c49460512.sptg)
	e1:SetOperation(c49460512.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡为同调素材的同调召唤成功时，对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c49460512.limitcon)
	e2:SetOperation(c49460512.limitop)
	c:RegisterEffect(e2)
end
-- 检查被破坏送入墓地的怪兽是否为名字带有「黑羽」的怪兽且为我方控制者且之前在主要怪兽区正面表示
function c49460512.cfilter(c,tp)
	return c:IsSetCard(0x33) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetReason(),0x41)==0x41
end
-- 判断是否有满足条件的怪兽被破坏送入墓地
function c49460512.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49460512.cfilter,1,nil,tp)
end
-- 判断是否可以特殊召唤此卡
function c49460512.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断我方场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c49460512.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断该卡是否作为同调素材被使用
function c49460512.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 设置连锁限制条件
function c49460512.limitop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁只能由发动者处理
	Duel.SetChainLimitTillChainEnd(c49460512.chainlm)
end
-- 连锁限制函数，确保只有发动者能处理连锁
function c49460512.chainlm(e,rp,tp)
	return tp==rp
end
