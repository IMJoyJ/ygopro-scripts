--転生竜サンサーラ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「转生龙」的效果1回合只能使用1次。
-- ①：场上的这张卡被对方的效果送去墓地的场合或者被战斗破坏送去墓地的场合，以「转生龙」以外的自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c29143726.initial_effect(c)
	-- 为转生龙添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
-- 效果发动条件：对方的效果将转生龙送去墓地且转生龙在场上时被送去墓地
function c29143726.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动条件：转生龙被战斗破坏送去墓地
function c29143726.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤满足条件的墓地怪兽，排除转生龙自身且可以特殊召唤
function c29143726.filter(c,e,tp)
	return not c:IsCode(29143726) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件，判断是否满足特殊召唤的条件
function c29143726.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c29143726.filter(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c29143726.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c29143726.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果操作，将选中的怪兽特殊召唤到场上
function c29143726.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
