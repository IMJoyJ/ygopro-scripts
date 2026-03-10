--マジェスペクター・ガスト
-- 效果：
-- ①：以自己的灵摆区域1张「威风妖怪」卡为对象才能发动。那张卡特殊召唤。
function c5153769.initial_effect(c)
	-- 效果原文内容：①：以自己的灵摆区域1张「威风妖怪」卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5153769.target)
	e1:SetOperation(c5153769.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「威风妖怪」卡，该卡可以被特殊召唤
function c5153769.filter(c,e,tp)
	return c:IsSetCard(0xd0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，检查玩家灵摆区是否有符合条件的卡
function c5153769.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c5153769.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家灵摆区是否存在至少一张符合条件的卡
		and Duel.IsExistingTarget(c5153769.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡，从玩家灵摆区选择一张符合条件的卡作为对象
	local g=Duel.SelectTarget(tp,c5153769.filter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c5153769.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示形式特殊召唤到玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
