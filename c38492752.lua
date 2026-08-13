--ラヴァル・キャノン
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以选择从游戏中除外的1只自己的名字带有「熔岩」的怪兽特殊召唤。
function c38492752.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，可以选择从游戏中除外的1只自己的名字带有「熔岩」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38492752,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c38492752.sptg)
	e1:SetOperation(c38492752.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的怪兽：必须是从游戏中除外、表侧表示、名字带有「熔岩」、且可以被当前效果特殊召唤的自己怪兽。
function c38492752.filter(c,e,tp)
	return c:IsSetCard(0x39) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点合法检查：存在可选的「熔岩」除外怪兽且自己场上留有特殊召唤空位；若为连锁处理中的对象检查，则验证指定对象是否仍满足上述条件。
function c38492752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c38492752.filter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在至少1只满足过滤器条件的「熔岩」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c38492752.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作玩家弹出选择提示，要求其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己除外区满足条件的怪兽中选择1张，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,c38492752.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息登记为：特殊召唤1只怪兽，供后续效果处理及联动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理部分：取得对象怪兽，若对象仍与效果关联（未离场或解除关系），则将其特殊召唤。
function c38492752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动该效果时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
