--霞の谷の雷鳥
-- 效果：
-- 场上表侧表示存在的这张卡回到手卡时，这张卡在自己场上特殊召唤。这个效果特殊召唤成功的回合，这张卡不能进行攻击。
function c69448290.initial_effect(c)
	-- 场上表侧表示存在的这张卡回到手卡时，这张卡在自己场上特殊召唤。这个效果特殊召唤成功的回合，这张卡不能进行攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69448290,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c69448290.spcon)
	e1:SetTarget(c69448290.sptg)
	e1:SetOperation(c69448290.spop)
	c:RegisterEffect(e1)
end
-- 检查这张卡在回到手牌前是否在场上表侧表示存在
function c69448290.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 定义效果的发动准备（Target）函数，因为是必发效果，直接返回true，并设置特殊召唤的操作信息
function c69448290.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息，表明将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果的处理（Operation）函数，处理特殊召唤以及特殊召唤成功后不能攻击的限制，若无怪兽区域空位则送去墓地
function c69448290.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检查自己场上的主要怪兽区域是否已满
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		-- 因无法特殊召唤，通过效果将该卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将该卡在自己场上表侧表示特殊召唤，并检查是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤成功的回合，这张卡不能进行攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
