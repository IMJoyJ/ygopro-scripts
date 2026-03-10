--チューナー・キャプチャー
-- 效果：
-- 对方对同调怪兽的同调召唤成功时才能发动。那1只作为同调素材的调整从对方墓地在自己场上特殊召唤。
function c50951359.initial_effect(c)
	-- 效果原文内容：对方对同调怪兽的同调召唤成功时才能发动。那1只作为同调素材的调整从对方墓地在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50951359.condition)
	e1:SetTarget(c50951359.target)
	e1:SetOperation(c50951359.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否为对方的同调召唤成功且不是自己发动的
function c50951359.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonType(SUMMON_TYPE_SYNCHRO) and ep~=tp
end
-- 规则层面作用：过滤满足条件的卡片，必须是调整类型且可以被特殊召唤
function c50951359.filter(c,e,tp,mg)
	return mg:IsContains(c) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的目标选择逻辑，限定在对方墓地的调整怪兽中选择
function c50951359.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c50951359.filter(chkc,e,tp,eg:GetFirst():GetMaterial()) end
	-- 规则层面作用：检查己方场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：确认对方墓地中存在符合条件的调整怪兽可供选择
		and Duel.IsExistingTarget(c50951359.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp,eg:GetFirst():GetMaterial()) end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择符合条件的目标卡片作为效果处理对象
	local g=Duel.SelectTarget(tp,c50951359.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg:GetFirst():GetMaterial())
	-- 规则层面作用：设置连锁操作信息，表明将要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：对方对同调怪兽的同调召唤成功时才能发动。那1只作为同调素材的调整从对方墓地在自己场上特殊召唤。
function c50951359.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标卡片以正面表示的形式特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
