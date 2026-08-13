--覇王龍の奇跡
-- 效果：
-- ①：自己场上有「霸王龙 扎克」存在的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己场上1张「霸王龙 扎克」破坏，从卡组·额外卡组把1只「异色眼」灵摆怪兽或者光属性「霸王龙 扎克」无视召唤条件特殊召唤。
-- ●自己的额外卡组1只表侧的灵摆怪兽在自己的灵摆区域放置。
-- ●从卡组把1张速攻魔法卡在自己场上盖放。
function c40456412.initial_effect(c)
	-- 登记这张卡的效果文中提到的「霸王龙 扎克」的卡号13331639，用于关联卡名判定。
	aux.AddCodeList(c,13331639)
	-- ①：自己场上有「霸王龙 扎克」存在的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。●自己场上1张「霸王龙 扎克」破坏，从卡组·额外卡组把1只「异色眼」灵摆怪兽或者光属性「霸王龙 扎克」无视召唤条件特殊召唤。●自己的额外卡组1只表侧的灵摆怪兽在自己的灵摆区域放置。●从卡组把1张速攻魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40456412,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c40456412.condition)
	e1:SetTarget(c40456412.target)
	e1:SetOperation(c40456412.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：卡片是表侧表示的「霸王龙 扎克」（卡号13331639）。
function c40456412.cfilter(c)
	return c:IsCode(13331639) and c:IsFaceup()
end
-- 发动条件函数：效果只能在满足条件时发动。实际判定自己场上是否有表侧「霸王龙 扎克」。
function c40456412.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「霸王龙 扎克」（场上包括怪兽区和魔陷区/灵摆区，这里用LOCATION_ONFIELD）。
	return Duel.IsExistingMatchingCard(c40456412.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 破坏筛选：选择自己场上表侧表示的「霸王龙 扎克」作为要破坏的卡。
function c40456412.desfilter(c)
	return c:IsCode(13331639) and c:IsFaceup()
end
-- 特殊召唤候选筛选：候选必须是「异色眼」灵摆怪兽，或光属性的「霸王龙 扎克」；且要能从卡组或额外卡组特殊召唤（有对应区域空格），并允许无视召唤条件特殊召唤。
function c40456412.spfilter(c,e,tp)
	return ((c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)) or (c:IsCode(13331639) and c:IsAttribute(ATTRIBUTE_LIGHT)))
		-- 若候选卡位于卡组，则需要自己的主要怪兽区有空位。
		and ((c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 若候选卡位于额外卡组，则需要额外卡组怪兽可用的特殊召唤区域空格数大于0（计算将该卡特殊召唤时是否有空格）。
		or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 灵摆放置筛选：选择额外卡组表侧表示的灵摆怪兽，且该卡未被禁止。
function c40456412.psfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
-- 盖放筛选：选择卡组中的速攻魔法卡，且该卡当前可以被盖放。
function c40456412.ssfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 发动时的目标处理：确认三个选项在当前是否分别可用，让玩家择一发动；记录选择的选项并设置操作信息。
function c40456412.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己场上所有表侧「霸王龙 扎克」作为选项1的破坏候选集合。
	local g1=Duel.GetMatchingGroup(c40456412.desfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 取得卡组与额外卡组中所有满足spfilter的特殊召唤候选集合。
	local g2=Duel.GetMatchingGroup(c40456412.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
	-- 选项1的可用条件：本回合尚未选择过选项1（若正处于cost检查阶段则临时不检查次数），且存在可破坏的扎克和可特殊召唤的候选。
	local b1=(Duel.GetFlagEffect(tp,40456412+1)==0 or not e:IsCostChecked())
		and g1:GetCount()>0 and g2:GetCount()>0
	-- 选项2的可用条件：本回合尚未选择过选项2（若正处于cost检查阶段则临时不检查次数），且灵摆区域有空位，且额外卡组有符合条件的灵摆怪兽。
	local b2=(Duel.GetFlagEffect(tp,40456412+2)==0 or not e:IsCostChecked())
		-- 检查自己的灵摆区域左右两侧是否至少有一个空格可用。
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查额外卡组是否存在符合psfilter的卡（表侧灵摆怪兽且未被禁止）。
		and Duel.IsExistingMatchingCard(c40456412.psfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 选项3的可用条件：本回合尚未选择过选项3（若正处于cost检查阶段则临时不检查次数），且卡组中存在可盖放的速攻魔法卡。
	local b3=(Duel.GetFlagEffect(tp,40456412+3)==0 or not e:IsCostChecked())
		-- 检查卡组中是否存在符合ssfilter的速攻魔法卡。
		and Duel.IsExistingMatchingCard(c40456412.ssfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 调用选项选择函数，让玩家在当前可用的效果项中选择一个，返回的选项编号存入变量op。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(40456412,1)},  --"破坏并特殊召唤"
		{b2,aux.Stringid(40456412,2)},  --"从额外卡组放置灵摆怪兽"
		{b3,aux.Stringid(40456412,3)})  --"从卡组盖放速攻魔法卡"
	if e:IsCostChecked() then
		-- 为当前玩家注册一个标志效果（code=40456412+op），持续到结束阶段；用于记录本回合已选择过第op个选项，限制该选项本回合不能再次使用。
		Duel.RegisterFlagEffect(tp,40456412+op,RESET_PHASE+PHASE_END,0,1)
	end
	e:SetLabel(op)
	if op==1 then
		-- 设置操作信息：本连锁包含破坏效果，对象为g1中的卡，数量为1；供星尘龙等卡进行连锁检测。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
		-- 设置操作信息：本连锁包含特殊召唤效果，特殊召唤对象在卡组·额外卡组，数量为1（对象具体在处理时确定，故为nil）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(0)
		end
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SSET)
		end
	end
end
-- 效果处理分发函数：根据发动时存入的选项编号op，分别调用spop（破坏+特召）、psop（放置灵摆）或ssop（盖放速攻）。
function c40456412.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		c40456412.spop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		c40456412.psop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		c40456412.ssop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 选项1的处理：选择1张自己场上的表侧「霸王龙 扎克」破坏；若破坏成功且仍有可特殊召唤的候选，则选择1只候选怪兽特殊召唤。
function c40456412.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧「霸王龙 扎克」作为破坏对象。
	local g1=Duel.SelectMatchingCard(tp,c40456412.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 处理时重新取得当前可特殊召唤的候选集合（卡组·额外卡组）。
	local g2=Duel.GetMatchingGroup(c40456412.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
	-- 如果破坏成功（返回>0）且候选集合非空，则继续执行特殊召唤。
	if Duel.Destroy(g1,REASON_EFFECT)>0 and g2:GetCount()>0 then
		-- 显示选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g2:Select(tp,1,1,nil)
		-- 将选择的怪兽以表侧表示、无视召唤条件（nocheck=true）特殊召唤到自己场上。
		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 选项2的处理：从额外卡组选择1只表侧灵摆怪兽，放置到自己的灵摆区域。
function c40456412.psop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的灵摆区域两个位置都不可用，则无法处理，直接退出。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 显示选择提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从额外卡组选择1只满足psfilter的表侧灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c40456412.psfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将所选灵摆怪兽移动到自己的灵摆区域，表侧放置；随后手动将其效果设为有效状态。
	if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,false) then
		tc:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end
-- 选项3的处理：从卡组选择1张速攻魔法卡，盖放到自己场上。
function c40456412.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足ssfilter的速攻魔法卡。
	local g=Duel.SelectMatchingCard(tp,c40456412.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的速攻魔法卡盖放到自己场上（从卡组）。
		Duel.SSet(tp,g:GetFirst())
	end
end
