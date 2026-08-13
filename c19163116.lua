--ジェムナイト・オブシディア
-- 效果：
-- ①：这张卡从手卡送去墓地的场合，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c19163116.initial_effect(c)
	-- ①：这张卡从手卡送去墓地的场合，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19163116,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c19163116.spcon)
	e1:SetTarget(c19163116.sptg)
	e1:SetOperation(c19163116.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定此卡被送去墓地前是否位于手牌，以满足“从手卡送去墓地”的场合。
function c19163116.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 目标筛选条件：墓地中1只4星以下的通常怪兽，且能够被特殊召唤。
function c19163116.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时与对象合法性判定：当有指定对象时确认其合法；在发动时检查场上空位和墓地对象是否满足。
function c19163116.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c19163116.filter(chkc,e,tp) end
	-- 若为发动时检查（chk==0），首先确认自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己墓地存在1只满足条件的通常怪兽可作为对象；若两者均满足则发动合法。
		and Duel.IsExistingTarget(c19163116.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示：请玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的通常怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c19163116.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记特殊召唤的操作信息，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：在场上仍有空位且对象仍有效时，将对象特殊召唤。
function c19163116.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前确认：若自己场上已无可用怪兽区域，则本次处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上（不进行召唤条件/苏生限制检查）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
