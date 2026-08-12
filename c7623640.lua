--暗黒界の導師 セルリ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡在对方场上守备表示特殊召唤。
-- ②：这张卡用「暗黑界」卡的效果特殊召唤成功的场合发动。对方选自身1张手卡丢弃。
function c7623640.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡在对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7623640,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c7623640.spcon)
	e1:SetTarget(c7623640.sptg)
	e1:SetOperation(c7623640.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡用「暗黑界」卡的效果特殊召唤成功的场合发动。对方选自身1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7623640,1))
	e2:SetCategory(CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c7623640.hdcon)
	e2:SetTarget(c7623640.hdtg)
	e2:SetOperation(c7623640.hdop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否是从手牌被效果丢弃并送去墓地
function c7623640.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 特殊召唤效果的发动准备与操作信息设置
function c7623640.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，将自身特殊召唤到对方场上
function c7623640.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧守备表示特殊召唤到对方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断此卡是否是通过「暗黑界」卡片的效果特殊召唤成功
function c7623640.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x6)
end
-- 丢弃手卡效果的发动准备与操作信息设置
function c7623640.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 丢弃手卡效果的处理，让对方选择自身1张手卡丢弃
function c7623640.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家选择并因效果丢弃1张手卡
	Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
end
