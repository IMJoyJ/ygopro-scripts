--リトル・オポジション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：指定相同纵列的没有使用的主要怪兽区域2处才能发动。自己让以下效果适用。那之后，对方可以让以下效果适用。
-- ●从自身的手卡·卡组选1只2星以下的怪兽在指定的自身的主要怪兽区域表侧攻击表示或里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册“小对抗”的发动效果，设置其描述、分类、类型、发动时点、1回合1次的发动次数限制，并指定发动时的目标选择函数和效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：指定相同纵列的没有使用的主要怪兽区域2处才能发动。自己让以下效果适用。那之后，对方可以让以下效果适用。●从自身的手卡·卡组选1只2星以下的怪兽在指定的自身的主要怪兽区域表侧攻击表示或里侧守备表示特殊召唤。
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
-- 筛选满足条件的怪兽：等级为2星以下，并且能被该效果以表侧攻击表示或里侧守备表示特殊召唤到指定区域z。
function s.filter(c,e,tp,z)
	return c:IsLevelBelow(2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE,tp,z)
end
-- 效果发动前的目标指定与合法性判断：先计算满足“相同纵列且双方对应区域均未使用”的自己可用主要怪兽区域；确认手卡·卡组中存在可特殊召唤的2星以下怪兽后，让玩家选择一个自己的主要怪兽区域，记录该区域并提示对方所选纵列。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local z=0
	for i=0,4 do
		-- 遍历主要怪兽区域0-4，若自己该列区域可用且对方镜像列（4-i）也可用，则将这个纵列标记累加到z中，用于表示符合“相同纵列且两处都没有使用”的区域。
		if Duel.CheckLocation(tp,LOCATION_MZONE,i) and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i) then z=z|2^i end
	end
	-- 效果发动合法性检查：自己手卡·卡组中存在至少1只满足过滤条件的2星以下怪兽，才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,z) end
	-- 显示“请选择要移动到的位置”的区域选择提示，引导玩家选择自己要使用的主要怪兽区域。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 玩家从满足条件的可用主要怪兽区域中选择1个区域，返回该区域的位标记并存入局部变量s。
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~z)
	local ts=math.log(s,2)
	e:SetLabel(s)
	-- 向双方展示玩家选择的区域，并根据镜像关系计算出对方对应纵列的区域标记，一并作为区域提示发送给玩家。
	Duel.Hint(HINT_ZONE,tp,s|2^(4-ts)<<16)
end
-- 效果处理时：先由自己从手卡·卡组选1只2星以下怪兽特殊召唤到发动时选择的自己主要怪兽区域，若里侧表示则给对方确认；若对方对应镜像区域仍空闲且对方手卡·卡组有符合条件的怪兽，则询问对方是否也适用效果，对方同意后同样特殊召唤1只怪兽到其镜像区域，并互相确认里侧表示的卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local z=e:GetLabel()
	-- 检查自己所选区域（z标记的区域）此刻是否仍可用；若没有可用格子则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,z)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，让自己选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选取1张满足过滤条件的2星以下怪兽，并取得该卡对象。
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,z):GetFirst()
	-- 将选中的怪兽以表侧攻击表示或里侧守备表示特殊召唤到之前选择的自己主要怪兽区域；特殊召唤成功后才继续处理对方是否适用效果。
	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE,z)>0 then
		-- 如果自己特殊召唤的怪兽是里侧守备表示，则向对方确认该卡，让对方知道召唤了什么怪兽。
		if sc:IsFacedown() then Duel.ConfirmCards(1-tp,sc) end
		local sq=4-sc:GetSequence()
		-- 获取对方手卡·卡组中满足条件的2星以下怪兽，并限定这些怪兽能够被特殊召唤到对方镜像纵列区域（2^sq）的候选集合。
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_DECK+LOCATION_HAND,nil,e,1-tp,2^sq)
		-- 判断对方对应的镜像主要怪兽区域是否仍然空闲，且对方存在可选的符合条件的怪兽；这是对方能够适用效果的前提条件之一。
		if Duel.CheckLocation(1-tp,LOCATION_MZONE,sq) and #g>0
			-- 询问对方是否也要适用这个效果（从自身手卡·卡组特殊召唤怪兽），并显示对应的选择提示。
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否选怪兽特殊召唤？"
			-- 显示“请选择要特殊召唤的卡”的提示，让对方选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc2=g:Select(1-tp,1,1,nil):GetFirst()
			-- 中断当前效果链路，使对方随后的特殊召唤视为不同时处理，避免与此前的处理错开时点造成规则问题。
			Duel.BreakEffect()
			-- 将对方选择的怪兽以表侧攻击表示或里侧守备表示特殊召唤到对方对应的镜像纵列主要怪兽区域。
			Duel.SpecialSummon(sc2,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE,2^sq)
			-- 如果对方特殊召唤的怪兽是里侧守备表示，则向自己确认该卡，让自己知道对方召唤了什么怪兽。
			if sc2:IsFacedown() then Duel.ConfirmCards(tp,sc2) end
		end
	end
end
