--魔轟神獣ケルベラル
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
function c82888408.initial_effect(c)
	-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82888408,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c82888408.spcon)
	e1:SetTarget(c82888408.sptg)
	e1:SetOperation(c82888408.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡之前的位置是手牌，且送去墓地的原因为丢弃
function c82888408.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 效果发动的目标：作为必发效果直接返回true，并设置特殊召唤自身的操作信息
function c82888408.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身特殊召唤1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡在墓地且与效果相关联，则将这张卡特殊召唤
function c82888408.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡正面表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
