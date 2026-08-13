--マジェスペクター・ガスト
-- 效果：
-- ①：以自己的灵摆区域1张「威风妖怪」卡为对象才能发动。那张卡特殊召唤。
function c5153769.initial_effect(c)
	-- ①：以自己的灵摆区域1张「威风妖怪」卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5153769.target)
	e1:SetOperation(c5153769.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择的灵摆区卡片过滤器：必须是「威风妖怪」字段的卡，且能够被特殊召唤（不检查召唤条件与苏生限制）。
function c5153769.filter(c,e,tp)
	return c:IsSetCard(0xd0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的取对象判定：若在连锁中指定对象，则检查对象位于自己灵摆区且满足过滤器；若是发动合法性判定，则检查自己场上是否有空余的主要怪兽区，且存在符合条件的对象可选。
function c5153769.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c5153769.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的主要怪兽区，以免特殊召唤时无格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己灵摆区是否存在至少1张「威风妖怪」且可以被特殊召唤的卡，作为发动的必要条件。
		and Duel.IsExistingTarget(c5153769.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡，给出选择对话框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己灵摆区选择1张符合条件的「威风妖怪」卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c5153769.filter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 将本连锁的操作信息设为特殊召唤该对象1张卡，用于后续时点/效果互动的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时执行特殊召唤：取出之前选择的对象，若它仍与效果相关，则将其以表侧表示特殊召唤到自己场上。
function c5153769.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那张对象卡（本效果只选择1张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
