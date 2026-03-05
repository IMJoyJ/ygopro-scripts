--魔轟神クルス
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合，以自己墓地1只其他的4星以下的「魔轰神」怪兽为对象发动。那只怪兽特殊召唤。
function c19439119.initial_effect(c)
	-- 效果原文内容：①：这张卡从手卡丢弃去墓地的场合，以自己墓地1只其他的4星以下的「魔轰神」怪兽为对象发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19439119,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c19439119.spcon)
	e1:SetTarget(c19439119.sptg)
	e1:SetOperation(c19439119.spop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断此卡是否由手牌丢弃进入墓地
function c19439119.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 规则层面操作：筛选满足等级4以下、魔轰神卡名、可特殊召唤条件的墓地怪兽
function c19439119.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置选择目标为满足条件的墓地怪兽，并设置操作信息为特殊召唤
function c19439119.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19439119.filter(chkc,e,tp) and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 规则层面操作：向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的1只墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c19439119.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 规则层面操作：设置连锁操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：①：这张卡从手卡丢弃去墓地的场合，以自己墓地1只其他的4星以下的「魔轰神」怪兽为对象发动。那只怪兽特殊召唤。
function c19439119.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
