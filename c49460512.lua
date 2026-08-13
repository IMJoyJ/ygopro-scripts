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
-- 判定送入墓地的怪兽是否满足触发条件：须为名字带有「黑羽」的怪兽，且之前由自己控制、在主要怪兽区表侧表示，并因卡的效果破坏而被送去墓地。
function c49460512.cfilter(c,tp)
	return c:IsSetCard(0x33) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetReason(),0x41)==0x41
end
-- 检测本次送去墓地的卡组中是否存在至少1张满足上述触发条件的「黑羽」怪兽。
function c49460512.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49460512.cfilter,1,nil,tp)
end
-- 特殊召唤的发动条件：在效果发动时若自己场上有空余的怪兽区且此卡可以被特殊召唤，则允许发动。
function c49460512.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区是否还有空位，作为此特殊召唤效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果处理将进行的特殊召唤操作信息，标明要对这张卡进行特殊召唤，供连锁中其他卡进行响应与检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡仍与效果关联（未被无效或移动），则将这张卡特殊召唤到自己场上。
function c49460512.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧攻击表示特殊召唤到自己场上，且不检查召唤条件、不检查苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 触发条件：此卡作为素材时，仅当该次召唤为同调召唤（REASON_SYNCHRO）时才适用本效果。
function c49460512.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 同调召唤成功时，设置连锁限制，使对方玩家在这条连锁结束前不能发动魔法·陷阱·效果怪兽的效果。
function c49460512.limitop(e,tp,eg,ep,ev,re,r,rp)
	-- 设定一个维持到连锁结束的连锁限制条件，具体限制内容由chainlm函数进行判定。
	Duel.SetChainLimitTillChainEnd(c49460512.chainlm)
end
-- 限制判定函数：只允许当前进行同调召唤的玩家发动效果，对方玩家不能发动魔法·陷阱·效果怪兽的效果。
function c49460512.chainlm(e,rp,tp)
	return tp==rp
end
