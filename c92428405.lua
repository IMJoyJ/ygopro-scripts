--覇王龍の魂
-- 效果：
-- ①：把基本分支付一半才能发动。把1只「霸王龙 扎克」从额外卡组无视召唤条件并效果无效特殊召唤。那只怪兽在下个回合的结束阶段回到持有者的额外卡组。
-- ②：对方把魔法卡的效果发动时，把墓地的这张卡和自己场上1只「霸王龙 扎克」除外才能发动。从自己的手卡·卡组·额外卡组·墓地选「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各最多1只特殊召唤。
function c92428405.initial_effect(c)
	-- 注册卡片「霸王龙 扎克」（密码：13331639）到本卡的关联卡片列表中。
	aux.AddCodeList(c,13331639)
	-- ①：把基本分支付一半才能发动。把1只「霸王龙 扎克」从额外卡组无视召唤条件并效果无效特殊召唤。那只怪兽在下个回合的结束阶段回到持有者的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92428405,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c92428405.cost)
	e1:SetTarget(c92428405.target)
	e1:SetOperation(c92428405.activate)
	c:RegisterEffect(e1)
	-- ②：对方把魔法卡的效果发动时，把墓地的这张卡和自己场上1只「霸王龙 扎克」除外才能发动。从自己的手卡·卡组·额外卡组·墓地选「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各最多1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92428405,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c92428405.spcon)
	e2:SetCost(c92428405.spcost)
	e2:SetTarget(c92428405.sptg)
	e2:SetOperation(c92428405.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价（Cost）判定与执行函数。
function c92428405.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半的基本分。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤额外卡组中可以无视召唤条件特殊召唤的「霸王龙 扎克」的条件函数。
function c92428405.filter(c,e,tp)
	-- 检查卡片密码是否为「霸王龙 扎克」，且额外怪兽区域有空位，并且该卡可以无视召唤条件特殊召唤。
	return c:IsCode(13331639) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①号效果的发动目标（Target）判定与操作信息设置函数。
function c92428405.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「霸王龙 扎克」。
	if chk==0 then return Duel.IsExistingMatchingCard(c92428405.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①号效果的发动处理（Operation）主函数。
function c92428405.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「霸王龙 扎克」。
	local g=Duel.SelectMatchingCard(tp,c92428405.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功选出怪兽，则尝试将其以表侧表示无视召唤条件特殊召唤（分步处理）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		tc:RegisterFlagEffect(92428405,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 那只怪兽在下个回合的结束阶段回到持有者的额外卡组。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		-- 将当前回合数记录在延迟效果的Label中，用于后续判断是否到了“下个回合”。
		e3:SetLabel(Duel.GetTurnCount())
		e3:SetLabelObject(tc)
		e3:SetCondition(c92428405.tdcon)
		e3:SetOperation(c92428405.tdop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		-- 将将在下个回合结束阶段使怪兽回到额外卡组的延迟效果注册给玩家。
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end
-- 判定是否到了下个回合结束阶段的条件函数。
function c92428405.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 检查当前回合数是否不等于发动效果时的回合数（即至少到了下个回合），且该怪兽身上的标记依然存在。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(92428405)~=0
end
-- 执行让怪兽回到额外卡组的操作函数。
function c92428405.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动「霸王龙之魂」的效果。
	Duel.Hint(HINT_CARD,0,92428405)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回持有者的额外卡组。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- ②号效果的发动条件判定函数：对方把魔法卡的效果发动时。
function c92428405.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL)
end
-- 过滤自己场上可以作为Cost除外的「霸王龙 扎克」的条件函数。
function c92428405.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(13331639) and c:IsAbleToRemoveAsCost()
		-- 检查在除外该「霸王龙 扎克」后，是否仍能从手卡、卡组、额外卡组、墓地中特殊召唤至少1只符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c92428405.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤可以被特殊召唤的「灵摆龙」、「超量龙」、「同调龙」、「融合龙」怪兽的条件函数。
function c92428405.spfilter(c,e,tp,tc)
	if not (c:IsSetCard(0x10f2,0x2073,0x2017,0x1046) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查在作为Cost的怪兽离场后，额外卡组的怪兽是否有可用的特殊召唤区域。
		return Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
	else
		-- 检查在作为Cost的怪兽离场后，非额外卡组的怪兽是否有可用的怪兽区域。
		return Duel.GetMZoneCount(tp,tc)>0
	end
end
-- ②号效果的发动代价（Cost）判定与执行函数。
function c92428405.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 检查墓地的这张卡以及自己场上的1只「霸王龙 扎克」是否都可以作为代价除外。
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c92428405.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给玩家发送“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上的1只「霸王龙 扎克」。
	local g=Duel.SelectMatchingCard(tp,c92428405.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 将选中的卡片（墓地的这张卡和场上的「霸王龙 扎克」）表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②号效果的发动目标（Target）判定与操作信息设置函数。
function c92428405.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			return true
		end
		-- 检查手卡、卡组、额外卡组、墓地是否存在至少1只可以特殊召唤的符合条件的怪兽。
		return Duel.IsExistingMatchingCard(c92428405.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 设置连锁处理的操作信息，表示此效果包含从手卡、卡组、额外卡组、墓地特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 过滤额外卡组中里侧表示的融合、同调、超量怪兽的条件函数。
function c92428405.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤额外卡组中连接怪兽或表侧表示的灵摆怪兽的条件函数。
function c92428405.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 检查选中的怪兽组合是否符合特殊召唤位置限制（怪兽区域、额外怪兽区域数量限制）以及每种系列（灵摆龙、超量龙、同调龙、融合龙）最多各1只的限制。
function c92428405.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)<=ft1
		and g:FilterCount(c92428405.exfilter2,nil)<=ft2
		and g:FilterCount(c92428405.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
		and g:FilterCount(Card.IsSetCard,nil,0x10f2)<=1
		and g:FilterCount(Card.IsSetCard,nil,0x2073)<=1
		and g:FilterCount(Card.IsSetCard,nil,0x2017)<=1
		and g:FilterCount(Card.IsSetCard,nil,0x1046)<=1
end
-- ②号效果的发动处理（Operation）主函数。
function c92428405.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的普通怪兽区域数量。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取从额外卡组特殊召唤里侧融合、同调、超量怪兽时可用的怪兽区域数量。
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取从额外卡组特殊召唤连接怪兽或表侧灵摆怪兽时可用的怪兽区域数量。
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取自己场上总共可用的怪兽区域数量。
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	-- 计算受特定卡片效果限制后的额外卡组特殊召唤最大可用数量。
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if ft1>0 then loc=loc+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE end
	if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	-- 获取手卡、卡组、额外卡组、墓地中所有满足特殊召唤条件且不受「王家长眠之谷」影响的怪兽。
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c92428405.spfilter),tp,loc,0,nil,e,tp)
	if sg:GetCount()==0 then return end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local rg=sg:SelectSubGroup(tp,c92428405.gcheck,false,1,4,ft1,ft2,ft3,ect,ft)
	-- 将选中的怪兽（最多4只，各系列最多1只）表侧表示特殊召唤。
	Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
end
