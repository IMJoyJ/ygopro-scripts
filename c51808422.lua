--XX－セイバー フォルトロール
-- 效果：
-- 这张卡不能通常召唤。自己场上有「X-剑士」怪兽2只以上存在的场合才能特殊召唤。
-- ①：1回合1次，以自己墓地1只4星以下的「X-剑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c51808422.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 规则层面操作：设置该卡无法通过通常召唤方式特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 效果原文内容：自己场上有「X-剑士」怪兽2只以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c51808422.spcon)
	c:RegisterEffect(e2)
	-- 效果原文内容：①：1回合1次，以自己墓地1只4星以下的「X-剑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51808422,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c51808422.target)
	e3:SetOperation(c51808422.operation)
	c:RegisterEffect(e3)
end
-- 规则层面操作：过滤场上满足条件的「X-剑士」怪兽（正面表示）。
function c51808422.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 规则层面操作：检查自己场上有2只以上「X-剑士」怪兽且有足够怪兽区域。
function c51808422.spcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查自己场上是否有足够的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 规则层面操作：检查自己场上是否存在至少2只「X-剑士」怪兽。
		Duel.IsExistingMatchingCard(c51808422.spfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
-- 规则层面操作：过滤墓地满足条件的「X-剑士」怪兽（4星以下且可特殊召唤）。
function c51808422.filter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置效果发动时的目标选择条件为己方墓地的「X-剑士」怪兽。
function c51808422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51808422.filter(chkc,e,tp) end
	-- 规则层面操作：检查自己场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查己方墓地中是否存在满足条件的「X-剑士」怪兽。
		and Duel.IsExistingTarget(c51808422.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的墓地中的「X-剑士」怪兽作为目标。
	local g=Duel.SelectTarget(tp,c51808422.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面操作：设置连锁的操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面操作：执行效果处理，将目标怪兽特殊召唤到场上。
function c51808422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽以正面表示方式特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
