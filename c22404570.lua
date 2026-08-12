--終刻なる獄神影
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·额外卡组（表侧）·墓地把1只「狱神」怪兽特殊召唤。那之后，自己场上的怪兽种类（融合·同调·超量）数量的以下效果各能适用。
-- ●1种类以上：从对方卡组上面把3张卡里侧除外。
-- ●2种类以上：对方场上1张卡里侧除外。
-- ●3种类：对方手卡随机1张里侧除外。
local s,id,o=GetID()
-- 初始化卡片效果的函数，注册了魔法卡的发动效果，该效果包含特殊召唤「狱神」怪兽以及根据场上怪兽种类适用除外对方卡片的效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·额外卡组（表侧）·墓地把1只「狱神」怪兽特殊召唤。那之后，自己场上的怪兽种类（融合·同调·超量）数量的以下效果各能适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，筛选出表侧表示（或在非额外区域存在）的「狱神」怪兽，并根据其所在位置检查是否拥有可用的怪兽区域进行特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x1ce)
		-- 如果该卡不在额外卡组中，则检查普通怪兽区域是否拥有可用的格子。
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp)>0
			-- 如果该卡在额外卡组中，则检查是否拥有供额外卡组怪兽出场的格子。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果的发动准备与检查函数，判断手牌、额外卡组（表侧表示）和墓地中是否存在可特殊召唤的「狱神」怪兽，并声明特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前判断手牌、表侧额外卡组或墓地中是否存在至少1只符合召唤过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息，表明本效果包含在玩家场上特殊召唤1只怪兽的操作，卡片来源可以是手牌、额外卡组或者墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 过滤函数，筛选出自己场上表侧表示的融合、同调或超量怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 获取卡片类型中属于融合、同调和超量的部分。
function s.gettype(c)
	return bit.band(c:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 效果的执行处理函数，先在手牌/表侧额外卡组/墓地中选择1只「狱神」怪兽特殊召唤，若特殊召唤成功，则统计场上怪兽种类的数量，根据数量依次处理对方卡组顶除外、对方场上卡片除外、对方手牌除外的后续效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示消息，指示其选择进行特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌、额外卡组或墓地中选择1只不受墓地否定效果影响的「狱神」怪兽。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 判断选择的卡片组是否包含卡片，且将这些卡片成功特殊召唤到场上。
	if sg:GetCount()>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己场上表侧表示的所有属于融合、同调或超量的怪兽卡片组。
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		local ct=g:GetClassCount(s.gettype)
		-- 获取对方卡组最上方的3张卡片组。
		local dg=Duel.GetDecktopGroup(1-tp,3)
		if ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3
			-- 若场上存在至少1种类的怪兽，且对方卡组最上方有3张可以除外的卡，则询问玩家是否适用除外卡组的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否除外卡组？"
			-- 中断效果处理的连续性，使之后的除外操作与前面的召唤不视为同时处理。
			Duel.BreakEffect()
			-- 使下一个操作不检查是否需要洗切卡组，防止因除外卡组顶部的卡片导致系统自动洗卡。
			Duel.DisableShuffleCheck()
			-- ●1种类以上：从对方卡组上面把3张卡里侧除外。
			Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)
		end
		-- 若场上存在至少2种类的怪兽，且对方场上存在可以被除外的卡片。
		if ct>1 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN)
			-- 询问玩家是否适用除外场上卡片的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外场上？"
			-- 中断效果处理的连续性，使之后的除外操作与前面的效果不视为同时处理。
			Duel.BreakEffect()
			-- 向玩家显示选择提示消息，指示其选择要除外的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 让玩家从对方场上选择1张可除外的卡片。
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
			if tg:GetCount()>0 then
				-- 在场上为被选择的除外目标卡片显示选中动画。
				Duel.HintSelection(tg)
				-- ●2种类以上：对方场上1张卡里侧除外。
				Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
		-- 若场上存在全部3种类的怪兽，且对方手牌中存在可除外的卡片。
		if ct==3 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN)
			-- 询问玩家是否适用除外对方手牌的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外手卡？"
			-- 中断效果处理的连续性，使之后的除外操作与前面的效果不视为同时处理。
			Duel.BreakEffect()
			-- 获取对方手牌中可以被除外的全部卡片组。
			local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp,POS_FACEDOWN)
			if rg:GetCount()>0 then
				local ssg=rg:RandomSelect(tp,1)
				-- ●3种类：对方手手卡随机1张里侧除外。
				Duel.Remove(ssg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end
