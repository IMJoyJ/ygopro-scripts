--ブルーローズ・ドラゴン
-- 效果：
-- ①：场上的这张卡被破坏送去墓地时，以自己墓地1只「黑蔷薇龙」或者植物族怪兽为对象才能发动。那只怪兽特殊召唤。
function c98884569.initial_effect(c)
	-- 注册该卡片记有「黑蔷薇龙」（卡号73580471）的事实
	aux.AddCodeList(c,73580471)
	-- ①：场上的这张卡被破坏送去墓地时，以自己墓地1只「黑蔷薇龙」或者植物族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98884569,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c98884569.condition)
	e1:SetTarget(c98884569.target)
	e1:SetOperation(c98884569.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：这张卡原本在场上，并且因破坏而送去墓地
function c98884569.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤条件：自己墓地的植物族怪兽或「黑蔷薇龙」，且能被特殊召唤
function c98884569.filter(c,e,tp)
	return (c:IsRace(RACE_PLANT) or c:IsCode(73580471)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与操作信息设置
function c98884569.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c98884569.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足条件的、可作为特殊召唤对象的目标
	if chk==0 then return Duel.IsExistingTarget(c98884569.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只满足条件的墓地怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c98884569.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为：特殊召唤所选的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽特殊召唤
function c98884569.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
