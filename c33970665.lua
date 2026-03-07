--ポンコツの意地
-- 效果：
-- 选择在自己墓地存在的3只名字带有「废铁」的怪兽发动。对方选择那些中的1只。那只怪兽在自己或对方场上特殊召唤，其余的卡从游戏中除外。
function c33970665.initial_effect(c)
	-- 效果原文内容：选择在自己墓地存在的3只名字带有「废铁」的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33970665.target)
	e1:SetOperation(c33970665.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的卡片组，即名字带有「废铁」且可以被特殊召唤的怪兽。
function c33970665.filter(c,e,tp)
	return c:IsSetCard(0x24) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 效果作用：判断是否满足发动条件，即自己或对方场上存在空位，并且自己墓地存在3只名字带有「废铁」的怪兽。
function c33970665.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33970665.filter(chkc,e,tp) end
	-- 效果作用：判断自己场上是否存在空位。
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		-- 效果作用：判断自己墓地是否存在3只名字带有「废铁」的怪兽。
		and Duel.IsExistingTarget(c33970665.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 效果作用：提示玩家选择3只名字带有「废铁」的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(33970665,2))  --"请选择3只名字带有「废铁」的怪兽"
	-- 效果作用：选择3只名字带有「废铁」的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c33970665.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 效果作用：设置连锁操作信息，确定要特殊召唤的怪兽数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：对方选择那些中的1只。那只怪兽在自己或对方场上特殊召唤，其余的卡从游戏中除外。
function c33970665.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中被选择的怪兽组，并筛选出与当前效果相关的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：获取自己场上可用的怪兽区域数量。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果作用：获取对方场上可用的怪兽区域数量。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if g:GetCount()==0 or (ft1==0 and ft2==0) then return end
	-- 效果作用：提示对方玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	local s1=ft1>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local s2=ft2>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local op=0
	-- 效果作用：如果自己和对方都可特殊召唤，则让对方选择在自己或对方场上特殊召唤。
	if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(33970665,0),aux.Stringid(33970665,1))  --"在自己场上特殊召唤/在对方场上特殊召唤"
	-- 效果作用：如果只有自己可特殊召唤，则让对方选择在自己场上特殊召唤。
	elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(33970665,0))  --"在自己场上特殊召唤"
	-- 效果作用：如果只有对方可特殊召唤，则让对方选择在对方场上特殊召唤。
	elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(33970665,1))+1  --"在对方场上特殊召唤"
	else op=2 end
	-- 效果作用：将选中的怪兽在自己场上特殊召唤。
	if op==0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 效果作用：将选中的怪兽在对方场上特殊召唤。
	elseif op==1 then Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP) end
	g:RemoveCard(tc)
	-- 效果作用：将未被特殊召唤的其余怪兽从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
