--俊足のギラザウルス
-- 效果：
-- ①：这张卡可以从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合发动。对方可以选自身墓地1只怪兽特殊召唤。
function c45894482.initial_effect(c)
	-- ①：这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45894482.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤成功的场合发动。对方可以选自身墓地1只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetDescription(aux.Stringid(45894482,0))  --"对方特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c45894482.condition)
	e3:SetOperation(c45894482.operation)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则效果的发动条件：判断这张卡能否从手卡通过自身规则效果特殊召唤；若c为nil则作为规则询问直接返回true，否则要求此卡控制者的主要怪兽区有空位。
function c45894482.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡控制者的主要怪兽区是否有可用空格，有则满足特殊召唤条件。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ②效果的发动条件：这张卡通过①的规则效果（特殊召唤方式为SUMMON_TYPE_SPECIAL且带有SUMMON_VALUE_SELF标记）成功特殊召唤时成立。
function c45894482.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：选择对方墓地中能够被当前效果特殊召唤的怪兽，同时检查其召唤条件和苏生限制。
function c45894482.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理时的操作：在对方墓地存在可选怪兽且对方主要怪兽区有空位时，询问对方是否特殊召唤；若同意，由对方选择1只墓地怪兽并表侧表示特殊召唤到其场上。
function c45894482.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地中满足可特殊召唤条件且不受王家长眠之谷影响的全部怪兽集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c45894482.filter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp)
	-- 判断是否存在可选怪兽，并且对方主要怪兽区是否有空位，作为是否继续处理的先决条件。
	if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 询问对方玩家是否选择进行墓地特殊召唤；若对方选择“是”则继续后面的选卡和召唤处理。
		and Duel.SelectYesNo(1-tp,aux.Stringid(45894482,1)) then  --"是否特殊召唤？"
		-- 向对方玩家发出选择怪兽的提示信息，提示内容为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 将对方选择的1只墓地怪兽以表侧表示特殊召唤到对方场上（不忽略召唤条件和苏生限制）。
		Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
