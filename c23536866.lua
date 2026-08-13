--ゲイザー・シャーク
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择「间歇泉鲨」以外的自己墓地2只水属性·5星怪兽才能发动。选择的2只怪兽的效果无效特殊召唤，只用那2只为素材把1只水属性的超量怪兽超量召唤。「间歇泉鲨」的效果1回合只能使用1次。
function c23536866.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，选择「间歇泉鲨」以外的自己墓地2只水属性·5星怪兽才能发动。选择的2只怪兽的效果无效特殊召唤，只用那2只为素材把1只水属性的超量怪兽超量召唤。「间歇泉鲨」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23536866,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,23536866)
	-- 设置效果的发动代价为：把墓地的这张卡从游戏中除外（aux.bfgcost封装了除外自身作为cost）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c23536866.target)
	e1:SetOperation(c23536866.operation)
	c:RegisterEffect(e1)
end
-- 定义可选择的墓地怪兽条件：等级5、水属性、卡名不是「间歇泉鲨」、能成为效果对象且能被特殊召唤。
function c23536866.filter(c,e,tp)
	return c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(23536866)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义额外卡组可超量召唤的水属性超量怪兽条件：该怪兽能用mg中的2只怪兽作为素材进行超量召唤，且额外卡组怪兽有可用的特殊召唤区域。
function c23536866.xyzfilter(c,mg,tp)
	-- 判定该额外怪兽为水属性，且能用mg中任意2只怪兽作为XYZ素材进行超量召唤，同时额外卡组怪兽有格子可用。
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsXyzSummonable(mg,2,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 筛选第一只素材：要求墓地剩余怪兽中存在另一只素材，能与当前c组成2只素材并进行水属性超量召唤（通过mfilter2验证）。
function c23536866.mfilter1(c,mg,exg)
	return mg:IsExists(c23536866.mfilter2,1,c,c,exg)
end
-- 判定另一只素材mc与第一只素材c是否能作为2只素材进行超量召唤（额外卡组中存在可用这两只作素材的超量怪兽）。
function c23536866.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- effect的Target函数：负责效果发动时的对象选择。先在墓地获取候选素材组mg，在额外获取候选超量怪兽组exg；若为发动检查，则确认玩家可特殊召唤次数≥2、不受青眼精灵龙限制、主要怪兽区空位>1、且存在可用的超量怪兽；正式发动时选择2只素材并设为对象。
function c23536866.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中符合filter条件的怪兽集合，即「间歇泉鲨」以外的水属性5星且可特殊召唤的候选素材。
	local mg=Duel.GetMatchingGroup(c23536866.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取额外卡组中符合xyzfilter条件的超量怪兽集合，即可以用这些墓地怪兽作素材超量召唤的水属性超量怪兽。
	local exg=Duel.GetMatchingGroup(c23536866.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,tp)
	-- 发动合法性检查：当前玩家本回合还可进行至少2次特殊召唤（因为需要特殊召唤2只素材怪兽）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 发动合法性检查：自己主要怪兽区剩余空位必须大于1，以满足同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and exg:GetCount()>0 end
	-- 在选择第一只素材前，向玩家显示提示消息：请选择要特殊召唤的卡（从墓地选怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:FilterSelect(tp,c23536866.mfilter1,1,1,nil,mg,exg)
	local tc1=sg1:GetFirst()
	-- 在选择第二只素材前，再次显示同样的提示，让玩家选择与第一只不同的另一只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=mg:FilterSelect(tp,c23536866.mfilter2,1,1,tc1,tc1,exg)
	sg1:Merge(sg2)
	-- 将最终选中的2只墓地怪兽设置为当前连锁的效果对象（相当于取对象），使它们与效果关联。
	Duel.SetTargetCard(sg1)
	-- 设置操作信息：该效果将特殊召唤2只怪兽（category为特殊召唤），供系统进行效果判定和连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
-- 处理时的对象过滤条件：对象怪兽必须仍与效果关联且仍能被特殊召唤，防止处理前离场或被无效等情况。
function c23536866.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：先检查青眼精灵龙限制和主怪兽区空格；获取仍有效的对象g；将g中2只怪兽依次特殊召唤，并各赋予EFFECT_DISABLE和EFFECT_DISABLE_EFFECT使它们效果无效；完成特殊召唤后刷新场地，若2只怪兽仍在场上则从额外选择一只可用水属性超量怪兽，用这2只为素材进行超量召唤。
function c23536866.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认主要怪兽区空格≥2，否则不处理（防止处理时格子被占）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从当前连锁记录的对象卡中，筛选出仍与效果关联且能被特殊召唤的怪兽组g。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c23536866.filter2,nil,e,tp)
	if g:GetCount()<2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	-- 使用分步特殊召唤第一步：将第1只对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
	-- 使用分步特殊召唤第二步：将第2只对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
	-- 「选择的2只怪兽的效果无效特殊召唤」中的效果无效部分，此处通过EFFECT_DISABLE使怪兽效果无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	local e2=e1:Clone()
	tc2:RegisterEffect(e2)
	-- 「选择的2只怪兽的效果无效特殊召唤」中的效果无效部分，此处通过EFFECT_DISABLE_EFFECT使效果无效化。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	e3:SetValue(RESET_TURN_SET)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e3)
	local e4=e3:Clone()
	tc2:RegisterEffect(e4)
	-- 完成特殊召唤处理，将分步特殊召唤的怪兽正式判定为特殊召唤成功。
	Duel.SpecialSummonComplete()
	-- 立即刷新场地信息，确保之后的怪兽位置、状态等判断反映最新的战场情况。
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 在额外卡组中筛选当前可进行超量召唤的水属性超量怪兽（以场上2只素材g为对象）。
	local xyzg=Duel.GetMatchingGroup(c23536866.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,tp)
	if xyzg:GetCount()>0 then
		-- 在选择要超量召唤的怪兽前，向玩家显示提示消息：请选择要特殊召唤的卡（从额外选超量怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用场上的2只怪兽g作为XYZ素材，将选中的超量怪兽xyz进行超量召唤（特殊召唤到额外怪兽区/可用的主要怪兽区）。
		Duel.XyzSummon(tp,xyz,g)
	end
end
