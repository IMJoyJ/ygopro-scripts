--ティンダングル・ドロネー
-- 效果：
-- ①：自己墓地有「廷达魔三角」怪兽3种类以上存在，对方怪兽的攻击让自己受到战斗伤害时才能发动。那只攻击怪兽破坏，从额外卡组把1只「廷达魔三角之锐角地狱犬」特殊召唤。
-- ②：额外怪兽区域没有自己怪兽存在的场合，把墓地的这张卡除外，以自己墓地3只「廷达魔三角」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
function c99157310.initial_effect(c)
	-- ①：自己墓地有「廷达魔三角」怪兽3种类以上存在，对方怪兽的攻击让自己受到战斗伤害时才能发动。那只攻击怪兽破坏，从额外卡组把1只「廷达魔三角之锐角地狱犬」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c99157310.condition)
	e1:SetTarget(c99157310.target)
	e1:SetOperation(c99157310.activate)
	c:RegisterEffect(e1)
	-- ②：额外怪兽区域没有自己怪兽存在的场合，把墓地的这张卡除外，以自己墓地3只「廷达魔三角」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99157310,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c99157310.spcon)
	-- 设置效果②的发动代价为“把墓地的这张卡除外”（通过aux.bfgcost实现），发动时需要先将自己从墓地除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c99157310.sptg)
	e2:SetOperation(c99157310.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：卡片属于「廷达魔三角」系列（SetCard 0x10b）且为怪兽卡，用于判断墓地中符合条件的「廷达魔三角」怪兽。
function c99157310.cfilter1(c)
	return c:IsSetCard(0x10b) and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动条件：自己受到对方怪兽攻击造成的战斗伤害，且自己墓地存在至少3种类「廷达魔三角」怪兽。
function c99157310.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 战斗伤害的承受方是自己（ep==tp），并且攻击怪兽由对方控制（IsControler(1-tp)），即必须是对方怪兽的攻击让自己受到战斗伤害。
	return ep==tp and Duel.GetAttacker():IsControler(1-tp)
		-- 检索自己墓地满足cfilter1的「廷达魔三角」怪兽，并统计不同卡名的数量（GetClassCount(Card.GetCode)），要求至少3种类。
		and Duel.GetMatchingGroup(c99157310.cfilter1,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)>=3
end
-- 定义特召对象的过滤条件：必须是「廷达魔三角之锐角地狱犬」（卡号75119040），可以被效果特殊召唤，并且从额外卡组特殊召唤时有可用区域。
function c99157310.filter(c,e,tp)
	-- 过滤条件：对象卡是卡号75119040的「廷达魔三角之锐角地狱犬」；满足通常特殊召唤条件；Duel.GetLocationCountFromEx判断从额外卡组出场的空格可用。
	return c:IsCode(75119040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动时处理：取得攻击怪兽作为对象，确认攻击怪兽仍在场上且额外卡组存在满足条件的「廷达魔三角之锐角地狱犬」，并登记破坏与特殊召唤的操作信息。
function c99157310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前战斗阶段的攻击怪兽，作为效果的处理对象（要破坏的怪兽）。
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField()
		-- 检查额外卡组是否存在至少1张满足filter条件的「廷达魔三角之锐角地狱犬」，以此作为效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c99157310.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 将攻击怪兽设定为效果的对象（取对象），后续效果处理时通过它来破坏该怪兽。
	Duel.SetTargetCard(tg)
	-- 登记本次连锁将执行的“破坏”操作信息：破坏对象为攻击怪兽，数量1，来源为效果，供其他卡连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 登记本次连锁将执行的“特殊召唤”操作信息：从自己的额外卡组特殊召唤1只怪兽，对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的解决处理：取攻击怪兽，若它仍与此效果相关且仍与战斗相关，则将其破坏；破坏成功后再从额外卡组特召1只「廷达魔三角之锐角地狱犬」。
function c99157310.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时设置的对象（那只攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽仍存在于场上且与效果、战斗相关；若用效果将其成功破坏（Duel.Destroy返回破坏数量不为0），才继续后续特殊召唤。
	if tc:IsRelateToEffect(e) and tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给己方玩家显示“请选择要特殊召唤的卡”的选择提示，便于从额外卡组选择特召对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方玩家从额外卡组选择1张满足filter条件的「廷达魔三角之锐角地狱犬」。
		local g=Duel.SelectMatchingCard(tp,c99157310.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「廷达魔三角之锐角地狱犬」以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义过滤条件：怪兽所在区域序号>=5，即位于额外怪兽区域（主怪兽区为0-4），用于判断额外怪兽区域是否有怪兽。
function c99157310.cfilter2(c)
	return c:GetSequence()>=5
end
-- 效果②的发动条件：己方场上不存在位于额外怪兽区域的怪兽，即额外怪兽区域没有自己怪兽。
function c99157310.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区域是否存在满足cfilter2的卡片，若不存在则返回true，满足“额外怪兽区域没有自己怪兽”的发动条件。
	return not Duel.IsExistingMatchingCard(c99157310.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义效果②选择墓地对象的过滤条件：是「廷达魔三角」系列怪兽、能够成为效果对象、并且可以以里侧守备表示特殊召唤。
function c99157310.spfilter(c,e,tp)
	return c:IsSetCard(0x10b) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果②的发动时处理：确认己方未受青眼精灵龙限制、主怪兽区空格大于2、墓地存在至少3种类不同卡名的「廷达魔三角」怪兽，然后选择3张作为对象。
function c99157310.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地所有满足spfilter的「廷达魔三角」怪兽组，作为后续选择对象的候选集合。
	local g=Duel.GetMatchingGroup(c99157310.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 己方主怪兽区可用空格必须大于2，因为这次效果要特殊召唤3只怪兽（里侧守备表示需要主怪兽区空格）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and g:GetClassCount(Card.GetCode)>2 end
	-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择要特殊召唤的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从候选组中选择3张卡，且通过aux.dncheck保证选择的卡卡名互不相同（对应“同名卡最多1张”）。
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的3张墓地怪兽设置为效果的对象。
	Duel.SetTargetCard(tg)
	-- 登记本次连锁将特殊召唤这些对象怪兽，数量为选中卡数，供连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 效果②的解决处理：根据己方主怪兽区剩余空格数，将对象怪兽全部或部分以里侧守备表示特殊召唤，并向对方展示。
function c99157310.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 取得效果②发动时设定的对象卡，并筛选出仍然与效果相关的部分（排除已离场或不受影响的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<=0 or g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将仍然相关的对象怪兽全部以里侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家展示这些里侧守备表示特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,g)
	else
		-- 空格不足时，显示“请选择要特殊召唤的卡”的提示，让玩家选择实际能特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将玩家选出的部分怪兽以里侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家展示实际里侧守备表示特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,sg)
	end
end
