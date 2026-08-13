--妨げられた壊獣の眠り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上的怪兽全部破坏。那之后，从卡组把卡名不同的「坏兽」怪兽在自己·对方的场上各1只攻击表示特殊召唤。这个效果特殊召唤的怪兽不能把表示形式变更，可以攻击的场合必须作出攻击。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「坏兽」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c99330325.initial_effect(c)
	-- ①：场上的怪兽全部破坏。那之后，从卡组把卡名不同的「坏兽」怪兽在自己·对方的场上各1只攻击表示特殊召唤。这个效果特殊召唤的怪兽不能把表示形式变更，可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99330325,0))  --"破坏·特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,99330325+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c99330325.target)
	e1:SetOperation(c99330325.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只「坏兽」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99330325,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置第②效果的发动条件为「这个效果在这张卡送去墓地的回合不能发动」：通过aux.exccon检查当前回合是否为该卡送去墓地的回合，若是则该效果不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置第②效果的发动代价为「把墓地的这张卡除外」：使用aux.bfgcost从墓地除外自身作为发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c99330325.thtg)
	e2:SetOperation(c99330325.thop)
	c:RegisterEffect(e2)
end
-- 该过滤函数用于发动前的合法性检查：确认卡组中存在1只「坏兽」怪兽c，其没有苏生限制且可由自己以表侧攻击表示特殊召唤到自己场上，同时卡组中还存在另一只卡名不同且能满足chkfilter2的「坏兽」怪兽，从而保证能凑齐分别特殊召唤到双方场上的一对。
function c99330325.chkfilter1(c,e,tp)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and
		-- 判定该「坏兽」怪兽没有苏生限制（EFFECT_REVIVE_LIMIT），并且当前玩家可以将其以表侧攻击表示特殊召唤到自己场上。
		not c:IsHasEffect(EFFECT_REVIVE_LIMIT) and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP_ATTACK,tp,c)
		-- 确认卡组中存在另一只满足chkfilter2的「坏兽」怪兽（卡名不同且可特殊召唤到对方场上），作为发动前提之一。
		and Duel.IsExistingMatchingCard(c99330325.chkfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 该过滤函数用于效果处理时选择特殊召唤到对方场上的「坏兽」怪兽：要求是「坏兽」怪兽、与已选怪兽卡名不同、没有苏生限制，并且当前玩家可以将其以表侧攻击表示特殊召唤到对方场上。
function c99330325.chkfilter2(c,e,tp,cd)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and not c:IsCode(cd)
		-- 判定该「坏兽」怪兽没有苏生限制，并且当前玩家可以将其以表侧攻击表示特殊召唤到对方场上。
		and not c:IsHasEffect(EFFECT_REVIVE_LIMIT) and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP_ATTACK,1-tp,c)
end
-- 该过滤函数用于效果处理时从卡组选择特殊召唤到自己场上的「坏兽」怪兽：要求是「坏兽」怪兽、没有苏生限制、能够以表侧攻击表示特殊召唤到自己场上，并且卡组中存在另一只卡名不同且满足filter2的「坏兽」怪兽。
function c99330325.filter1(c,e,tp)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
		-- 确认卡组中存在另一只满足filter2的卡名不同的「坏兽」怪兽，用于保证能够同时特殊召唤两只（一只到自己，一只到对方）。
		and Duel.IsExistingMatchingCard(c99330325.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 该过滤函数用于效果处理时选择特殊召唤到对方场上的「坏兽」怪兽：要求是「坏兽」怪兽、与已选怪兽卡名不同、没有苏生限制，并且能够以表侧攻击表示特殊召唤到对方场上。
function c99330325.filter2(c,e,tp,cd)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and not c:IsCode(cd)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end
-- ①效果的发动合法性检测与操作信息设置：要求场上存在怪兽、双方场上在全部怪兽被破坏后仍有至少1个可用怪兽区域、且卡组中存在符合条件的「坏兽」组合；同时需要没有「青眼精灵龙」等禁止同时特殊召唤多只怪兽的效果生效。通过后设置本效果包含破坏全场怪兽和特殊召唤2只怪兽的信息。
function c99330325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查双方场上合计存在至少1只怪兽，以满足“场上的怪兽全部破坏”的发动前提。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0
		-- 判断自己场上的怪兽全部被破坏后，自己场上仍有至少1个可用怪兽区域（当前可用区域数+自己怪兽数>0），以便特殊召唤怪兽到自己场上。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 判断对方场上的怪兽全部被破坏后，对方场上仍有至少1个可用怪兽区域（当前可用区域数+对方怪兽数>0），以便特殊召唤怪兽到对方场上。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
		-- 确认卡组中存在至少一组符合条件的「坏兽」怪兽（一只可到自己场上，另一只卡名不同可到对方场上），从而满足发动条件。
		and Duel.IsExistingMatchingCard(c99330325.chkfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取当前双方场上全部怪兽，作为即将被「场上的怪兽全部破坏」效果处理的对象集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 设置操作信息：本连锁包含破坏效果，破坏对象为当前场上所有怪兽（数量为g的计数），用于后续连锁判定和替代破坏等互动的检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：本连锁包含特殊召唤效果，将从卡组特殊召唤2只怪兽（目标位置为卡组，持有者视为tp），由于具体特召卡在效果处理时选择，因此targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ①效果的实际处理：破坏场上所有怪兽；若破坏成功且卡组中存在符合条件的坏兽组合、双方场上各有空格，则从中各选1只坏兽，分别以表侧攻击表示特殊召唤到自己和对方场上，并给这些特殊召唤的怪兽附加“不能变更表示形式”和“可以攻击的场合必须攻击”的效果。
function c99330325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上全部怪兽，作为这次破坏的对象。
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 以效果破坏这些怪兽；若实际破坏数量为0则不再进行后续特殊召唤处理。
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	-- 从卡组筛选出所有可作为“特殊召唤到自己场上的坏兽”的候选怪兽集合（同时要求存在另一只卡名不同且能特殊召唤到对方场上的坏兽）。
	local sg=Duel.GetMatchingGroup(c99330325.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 在破坏后，双方场上都至少要有1个可用怪兽区域，才能分别特殊召唤1只坏兽到自己和对方场上。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 中断当前效果处理，使接下来的特殊召唤处理与前面的破坏处理不在同一时点连续处理，以避免错失时点或产生不正确的连锁互动。
		Duel.BreakEffect()
		-- 提示操作玩家从卡组选择1只要在自己场上特殊召唤的「坏兽」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(99330325,2))  --"请选择要在自己场上特殊召唤的怪兽"
		local g1=sg:Select(tp,1,1,nil)
		local tc1=g1:GetFirst()
		-- 提示操作玩家从卡组选择1只要在对方场上特殊召唤的「坏兽」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(99330325,3))  --"请选择要在对方场上特殊召唤的怪兽"
		-- 从卡组选择1只满足filter2的「坏兽」怪兽（与已选卡卡名不同且能特殊召唤到对方场上），作为特殊召唤到对方场上的对象。
		local g2=Duel.SelectMatchingCard(tp,c99330325.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc1:GetCode())
		local tc2=g2:GetFirst()
		-- 将第1只「坏兽」怪兽以表侧攻击表示特殊召唤到自己场上（作为特殊召唤过程的一步，尚未完成）。
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		-- 将第2只「坏兽」怪兽以表侧攻击表示特殊召唤到对方场上（作为特殊召唤过程的一步，尚未完成）。
		Duel.SpecialSummonStep(tc2,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
		-- 这个效果特殊召唤的怪兽不能把表示形式变更。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_MUST_ATTACK)
		e3:SetDescription(aux.Stringid(99330325,4))  --"「遭受妨碍的坏兽安眠」效果适用中"
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		tc1:RegisterEffect(e3)
		local e4=e3:Clone()
		tc2:RegisterEffect(e4)
		-- 完成通过SpecialSummonStep进行的所有特殊召唤处理，触发特殊召唤成功时的相关时点。
		Duel.SpecialSummonComplete()
	end
end
-- 第②效果检索的过滤函数：从卡组中筛选「坏兽」怪兽，且该怪兽可以被加入手卡。
function c99330325.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 第②效果的发动条件检查与操作信息设置：确认卡组中存在可检索的「坏兽」怪兽，并设置本效果包含回手牌（CATEGORY_TOHAND）分类，预备从卡组将1张卡加入手牌。
function c99330325.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1只满足thfilter的「坏兽」怪兽，以决定能否发动第②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c99330325.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组把1张卡加入手牌（对象不确定，targets为nil，count为1，位置为卡组，持有者为tp）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 第②效果的实际处理：从卡组选择1只「坏兽」怪兽加入手牌，并向对方玩家展示。
function c99330325.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示操作玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足thfilter的「坏兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c99330325.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那只「坏兽」怪兽加入持有者的手牌，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张「坏兽」怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
