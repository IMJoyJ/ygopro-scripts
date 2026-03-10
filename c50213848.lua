--取捨蘇生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地3只怪兽为对象才能发动。对方从作为对象的怪兽之中选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽全部除外。
function c50213848.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50213848+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c50213848.target)
	e1:SetOperation(c50213848.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查墓地怪兽是否可以被特殊召唤且能除外
function c50213848.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAbleToRemove()
end
-- 效果作用：设置连锁处理时的目标选择条件
function c50213848.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50213848.filter(chkc,e,tp) end
	-- 效果作用：判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：确认墓地是否存在3只符合条件的怪兽
		and Duel.IsExistingTarget(c50213848.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 效果作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从玩家墓地中选择3只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c50213848.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 效果作用：设置连锁操作信息，指定将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：①：以自己墓地3只怪兽为对象才能发动。对方从作为对象的怪兽之中选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽全部除外。
function c50213848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：筛选出与当前连锁相关的、可被特殊召唤的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	-- 效果作用：判断是否有足够的怪兽参与处理且场上存在召唤区域
	if g:GetCount()==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：向对方提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	-- 效果作用：将选定的怪兽特殊召唤到场上
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	g:RemoveCard(tc)
	-- 效果作用：将剩余的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
