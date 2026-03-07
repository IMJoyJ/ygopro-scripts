--徴兵令
-- 效果：
-- 检视对方卡组最上面的1张卡，如果那张卡是可以通常召唤的怪兽的场合，在自己场上特殊召唤。是其他卡的场合，那张卡加到对方的手卡。
function c31000575.initial_effect(c)
	-- 效果原文内容：检视对方卡组最上面的1张卡，如果那张卡是可以通常召唤的怪兽的场合，在自己场上特殊召唤。是其他卡的场合，那张卡加到对方的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31000575.target)
	e1:SetOperation(c31000575.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件
function c31000575.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：确认对方卡组最上方有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)~=0
		-- 效果作用：确认自己场上存在可用怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：确认自己未被效果63060238影响
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 效果作用：确认自己未被效果97148796影响
		and not Duel.IsPlayerAffectedByEffect(tp,97148796) end
end
-- 效果原文内容：检视对方卡组最上面的1张卡，如果那张卡是可以通常召唤的怪兽的场合，在自己场上特殊召唤。是其他卡的场合，那张卡加到对方的手卡。
function c31000575.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：确认对方卡组最上方1张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 效果作用：获取对方卡组最上方1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsSummonableCard() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 效果作用：禁止接下来的操作进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 效果作用：将目标怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif tc:IsAbleToHand() then
		-- 效果作用：禁止接下来的操作进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 效果作用：将目标卡送入对方手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 效果作用：洗切对方手卡
		Duel.ShuffleHand(1-tp)
	else
		-- 效果作用：禁止接下来的操作进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 效果作用：将目标卡送入墓地
		Duel.SendtoGrave(tc,REASON_RULE)
	end
end
