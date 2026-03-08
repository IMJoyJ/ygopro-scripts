--黙する死者
-- 效果：
-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能攻击。
function c42534368.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只通常怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42534368.target)
	e1:SetOperation(c42534368.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选满足条件的墓地通常怪兽
function c42534368.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：设置效果目标为己方墓地的通常怪兽
function c42534368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42534368.filter(chkc,e,tp) end
	-- 效果作用：判断己方场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断己方墓地是否存在满足条件的通常怪兽
		and Duel.IsExistingTarget(c42534368.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c42534368.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理效果发动后的特殊召唤及附加效果
function c42534368.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断己方场上是否有特殊召唤怪兽的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认对象卡有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 效果原文内容：这个效果特殊召唤的怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
