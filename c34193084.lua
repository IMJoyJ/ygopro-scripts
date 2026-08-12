--闇よりの恐怖
-- 效果：
-- 当这张卡被对方的效果从手卡或卡组送去墓地时，这张卡特殊召唤上场。
function c34193084.initial_effect(c)
	-- 当这张卡被对方的效果从手卡或卡组送去墓地时，这张卡特殊召唤上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34193084,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c34193084.spcon)
	e1:SetTarget(c34193084.sptg)
	e1:SetOperation(c34193084.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：卡片之前在手卡或卡组位置，且因对方效果进入墓地
function c34193084.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and bit.band(r,REASON_EFFECT)~=0 and rp==1-tp
end
-- 效果处理目标设定：将自身设置为特殊召唤的目标
function c34193084.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：标记此次连锁处理为特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理执行：若卡片与效果相关则进行特殊召唤
function c34193084.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行特殊召唤：将自身以正面表示方式特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
