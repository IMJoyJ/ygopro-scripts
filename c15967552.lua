--リトル・オポジション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：指定相同纵列的没有使用的主要怪兽区域2处才能发动。自己让以下效果适用。那之后，对方可以让以下效果适用。
-- ●从自身的手卡·卡组选1只2星以下的怪兽在指定的自身的主要怪兽区域表侧攻击表示或里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册小对抗的发动效果
function s.initial_effect(c)
	-- ①：指定相同纵列的没有使用的主要怪兽区域2处才能发动。自己让以下效果适用。那之后，对方可以让以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选2星以下且可特殊召唤的怪兽
function s.filter(c,e,tp,z)
	return c:IsLevelBelow(2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE,tp,z)
end
-- 处理小对抗的发动时点，检查可用区域并选择目标区域
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local z=0
	for i=0,4 do
		-- 检查玩家和对手在相同纵列的怪兽区域是否都为空
		if Duel.CheckLocation(tp,LOCATION_MZONE,i) and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i) then z=z|2^i end
	end
	-- 检查玩家手牌和卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,z) end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个可用的怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~z)
	local ts=math.log(s,2)
	e:SetLabel(s)
	-- 提示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,s|2^(4-ts)<<16)
end
-- 处理小对抗的效果发动
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local z=e:GetLabel()
	-- 检查玩家是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,z)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一张满足条件的怪兽进行特殊召唤
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,z):GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE,z)>0 then
		-- 如果特殊召唤的怪兽是里侧表示，则确认其卡面
		if sc:IsFacedown() then Duel.ConfirmCards(1-tp,sc) end
		local sq=4-sc:GetSequence()
		-- 获取对方可特殊召唤的怪兽组
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_DECK+LOCATION_HAND,nil,e,1-tp,2^sq)
		-- 检查对方的对应纵列区域是否可用且存在可选怪兽
		if Duel.CheckLocation(1-tp,LOCATION_MZONE,sq) and #g>0
			-- 询问对方是否选择怪兽特殊召唤
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否选怪兽特殊召唤？"
			-- 提示对方选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc2=g:Select(1-tp,1,1,nil):GetFirst()
			-- 中断当前效果，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将对方选择的怪兽特殊召唤到对应区域
			Duel.SpecialSummon(sc2,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE,2^sq)
			-- 如果特殊召唤的怪兽是里侧表示，则确认其卡面
			if sc2:IsFacedown() then Duel.ConfirmCards(tp,sc2) end
		end
	end
end
