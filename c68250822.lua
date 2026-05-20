--スプライト・ダブルクロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以以自己或对方的场上·墓地1只怪兽为对象，从以下效果选择1个发动。
-- ●把作为对象的怪兽作为自己场上1只2阶怪兽的超量素材。
-- ●作为对象的对方场上的怪兽在作为自己场上的连接2怪兽所连接区的自己场上放置得到控制权。
-- ●作为对象的墓地的怪兽在作为自己场上的连接2怪兽所连接区的自己场上特殊召唤。
function c68250822.initial_effect(c)
	-- ①：可以以自己或对方的场上·墓地1只怪兽为对象，从以下效果选择1个发动。●把作为对象的怪兽作为自己场上1只2阶怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68250822,0))  --"补充超量素材"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68250822+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c68250822.target1)
	e1:SetOperation(c68250822.operation1)
	c:RegisterEffect(e1)
	-- ①：可以以自己或对方的场上·墓地1只怪兽为对象，从以下效果选择1个发动。●作为对象的对方场上的怪兽在作为自己场上的连接2怪兽所连接区的自己场上放置得到控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68250822,1))  --"得到控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,68250822+EFFECT_COUNT_CODE_OATH)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c68250822.target2)
	e2:SetOperation(c68250822.operation2)
	c:RegisterEffect(e2)
	-- ①：可以以自己或对方的场上·墓地1只怪兽为对象，从以下效果选择1个发动。●作为对象的墓地的怪兽在作为自己场上的连接2怪兽所连接区的自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68250822,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,68250822+EFFECT_COUNT_CODE_OATH)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(c68250822.target3)
	e3:SetOperation(c68250822.operation3)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的2阶怪兽
function c68250822.filter1(c)
	return c:IsRank(2) and c:IsFaceup()
end
-- 过滤可以作为超量素材的怪兽，且自己场上存在其他2阶怪兽
function c68250822.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
		-- 检查自己场上是否存在除该怪兽以外的表侧表示2阶怪兽
		and Duel.IsExistingMatchingCard(c68250822.filter1,tp,LOCATION_MZONE,0,1,c)
end
-- 效果①（叠放素材）的发动准备与对象选择
function c68250822.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c68250822.cfilter1(chkc,tp) end
	-- 检查双方场上或墓地是否存在可以作为超量素材且自己场上有2阶怪兽对应的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68250822.cfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
	-- 设置选择要作为超量素材的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择双方场上或墓地的一只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68250822.cfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若对象在墓地，设置涉及离开墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果①（叠放素材）的效果处理
function c68250822.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 设置选择表侧表示卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上一只表侧表示的2阶怪兽
	local g=Duel.SelectMatchingCard(tp,c68250822.filter1,tp,LOCATION_MZONE,0,1,1,tc)
	if #g==0 then return end
	local tc2=g:GetFirst()
	if not tc:IsImmuneToEffect(e) and not tc2:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将该怪兽原本持有的超量素材因规则送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将作为对象的怪兽重叠在选择的2阶怪兽下方作为超量素材
		Duel.Overlay(tc2,Group.FromCards(tc))
	end
end
-- 获取自己场上所有连接2怪兽所连接区的区域掩码
function c68250822.getzone(tp)
	-- 获取自己场上所有的连接2怪兽
	local g=Duel.GetMatchingGroup(Card.IsLink,tp,LOCATION_MZONE,0,nil,2)
	local zone=0
	-- 遍历自己场上的连接2怪兽
	for lc in aux.Next(g) do
		zone=zone|lc:GetLinkedZone()
	end
	return zone&0x1f
end
-- 过滤可以改变控制权且能放置在指定区域的怪兽
function c68250822.filter2(c,zone)
	return c:IsControlerCanBeChanged(false,zone)
end
-- 效果②（转移控制权）的发动准备与对象选择
function c68250822.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=c68250822.getzone(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c68250822.filter2(chkc,zone) end
	-- 检查对方场上是否存在可以转移控制权到自己连接2怪兽所连接区的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68250822.filter2,tp,0,LOCATION_MZONE,1,nil,zone) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
	-- 设置选择要改变控制权怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上一只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68250822.filter2,tp,0,LOCATION_MZONE,1,1,nil,zone)
	-- 设置改变控制权的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果②（转移控制权）的效果处理
function c68250822.operation2(e,tp,eg,ep,ev,re,r,rp)
	local zone=c68250822.getzone(tp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将作为对象的怪兽放置在自己场上连接2怪兽所连接区并得到控制权
		Duel.GetControl(tc,tp,0,0,zone)
	end
end
-- 过滤可以特殊召唤到指定区域的怪兽
function c68250822.filter3(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果③（特殊召唤）的发动准备与对象选择
function c68250822.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=c68250822.getzone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c68250822.filter3(chkc,e,tp,zone) end
	-- 检查双方墓地是否存在可以特殊召唤到自己连接2怪兽所连接区的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68250822.filter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
	-- 设置选择要特殊召唤卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地的一只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68250822.filter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③（特殊召唤）的效果处理
function c68250822.operation3(e,tp,eg,ep,ev,re,r,rp)
	local zone=c68250822.getzone(tp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将作为对象的怪兽在自己场上连接2怪兽所连接区特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
