--剛鬼フェイスターン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张「刚鬼」卡和自己墓地1只「刚鬼」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。
function c26285557.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26285557+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26285557.target)
	e1:SetOperation(c26285557.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的场上刚鬼卡
function c26285557.desfilter(c,tp)
	-- 效果作用：满足条件的场上刚鬼卡必须表侧表示且有可用怪兽区
	return c:IsFaceup() and c:IsSetCard(0xfc) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果作用：检索满足条件的墓地刚鬼怪兽
function c26285557.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件
function c26285557.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 效果作用：满足条件的场上刚鬼卡存在
	if chk==0 then return Duel.IsExistingTarget(c26285557.desfilter,tp,LOCATION_ONFIELD,0,1,c,tp)
		-- 效果作用：满足条件的墓地刚鬼怪兽存在
		and Duel.IsExistingTarget(c26285557.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择满足条件的场上刚鬼卡作为破坏对象
	local g1=Duel.SelectTarget(tp,c26285557.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	-- 效果作用：提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的墓地刚鬼怪兽作为特殊召唤对象
	local g2=Duel.SelectTarget(tp,c26285557.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 效果作用：设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果原文内容：①：以自己场上1张「刚鬼」卡和自己墓地1只「刚鬼」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。
function c26285557.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的两个对象卡
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 效果作用：判断对象卡是否满足发动条件并执行破坏和特殊召唤
	if tc1:IsControler(tp) and tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToEffect(e) then
		-- 效果作用：将对象怪兽特殊召唤到场上
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
