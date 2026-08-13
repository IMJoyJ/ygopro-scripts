--転生竜サンサーラ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「转生龙」的效果1回合只能使用1次。
-- ①：场上的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合，以「转生龙」以外的自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c29143726.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合，以「转生龙」以外的自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29143726,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,29143726)
	e1:SetCondition(c29143726.spcon1)
	e1:SetTarget(c29143726.sptg)
	e1:SetOperation(c29143726.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c29143726.spcon2)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡被对方的效果从场上送去墓地（且之前由自己控制）
function c29143726.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动条件：这张卡被战斗破坏并送去墓地（当前在墓地且原因为战斗）
function c29143726.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 选择对象：墓地中除“转生龙”以外的、能够被特殊召唤的怪兽
function c29143726.filter(c,e,tp)
	return not c:IsCode(29143726) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：确认可特殊召唤的怪兽区，从双方墓地选择1只“转生龙”以外的可特殊召唤怪兽为对象
function c29143726.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c29143726.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认双方墓地存在至少1只满足条件的可特殊召唤怪兽作为对象
		and Duel.IsExistingTarget(c29143726.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家显示选择特殊召唤对象的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只墓地中的符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c29143726.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象，若对象仍与效果关联，则将其表侧表示特殊召唤到自己场上
function c29143726.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
