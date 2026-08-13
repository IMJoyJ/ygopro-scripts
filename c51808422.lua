--XX－セイバー フォルトロール
-- 效果：
-- 这张卡不能通常召唤。自己场上有「X-剑士」怪兽2只以上存在的场合才能特殊召唤。
-- ①：1回合1次，以自己墓地1只4星以下的「X-剑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c51808422.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「X-剑士」怪兽2只以上存在的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为恒为假，使这张卡无法通过其他卡片效果被特殊召唤（只能通过自身规则特殊召唤）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己场上有「X-剑士」怪兽2只以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c51808422.spcon)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以自己墓地1只4星以下的「X-剑士」怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 过滤条件：场上表侧表示且卡名含有「X-剑士」字段（0x100d）的怪兽。
function c51808422.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 特殊召唤规则的发动条件：可用主要怪兽区存在空格，且自己场上存在至少2只表侧表示的「X-剑士」怪兽。
function c51808422.spcon(e,c)
	if c==nil then return true end
	-- 检查该怪兽控制者的主要怪兽区是否有空位，空位大于0才可进行特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查该怪兽控制者场上是否存在至少2张表侧表示且含「X-剑士」字段的怪兽，作为特殊召唤的条件。
		Duel.IsExistingMatchingCard(c51808422.spfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
-- 对象选择过滤：墓地中满足「X-剑士」字段、等级4以下、且可以被特殊召唤的怪兽。
function c51808422.filter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 起动效果的发动判定与取对象判定：若是对象确认，则检查该卡是否为自己墓地符合条件的「X-剑士」怪兽；若是发动确认，则检查自己主要怪兽区有空位且墓地存在1只符合条件的对象。
function c51808422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51808422.filter(chkc,e,tp) end
	-- 效果发动时（chk==0）的合法性检查：自己主要怪兽区存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在1只符合条件的「X-剑士」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c51808422.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示，进入选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「X-剑士」怪兽作为效果对象，并将其与该效果建立关联。
	local g=Duel.SelectTarget(tp,c51808422.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次操作信息登记为特殊召唤1只怪兽，供后续连锁判定及效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的解决处理：取得效果对象，若该对象仍与效果关联（未离场或转移），则将其特殊召唤到自己场上。
function c51808422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的对象卡（仅有1只对象，直接取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 无视苏生限制与召唤条件，将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
