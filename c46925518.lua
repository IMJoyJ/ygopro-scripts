--ゴーストリックの人形
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转的场合发动。这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
function c46925518.initial_effect(c)
	-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c46925518.sumcon)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46925518,0))  --"变成里侧表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c46925518.postg)
	e2:SetOperation(c46925518.posop)
	c:RegisterEffect(e2)
	-- ②：这张卡反转的场合发动。这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_FLIP)
	e3:SetOperation(c46925518.fdop)
	c:RegisterEffect(e3)
end
-- 过滤条件：怪兽须为表侧表示且属于「鬼计」系列（0x8d）。
function c46925518.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 不能召唤的条件：当自己场上不存在表侧表示的「鬼计」怪兽时，此卡不能表侧表示召唤（满足“自己场上有「鬼计」怪兽存在的场合才能表侧表示召唤”的限制）。
function c46925518.sumcon(e)
	-- 检查以效果持有者视角的自己主要怪兽区是否存在至少1张表侧表示的「鬼计」怪兽；不存在时返回 true，从而使 EFFECT_CANNOT_SUMMON 生效。
	return not Duel.IsExistingMatchingCard(c46925518.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动检测与发动处理准备：首先取得此卡；chk==0 时确认此卡当前可变为里侧表示且本回合尚未用过该效果（flag=0）；满足条件后注册1回合1次的标识，并设置操作信息为改变表示形式。
function c46925518.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(46925518)==0 end
	c:RegisterFlagEffect(46925518,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：本次效果分类为改变表示形式（CATEGORY_POSITION），对象为此卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联且处于表侧表示，则将其变为里侧守备表示。
function c46925518.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡从表侧表示直接变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- ②反转时的处理：将此卡反转时触发的效果注册为结束阶段适用的延迟效果；该延迟效果在结束阶段若满足条件，则执行把所有表侧可翻转怪兽变成里侧守备表示并可能从卡组特殊召唤「鬼计」怪兽的处理。
function c46925518.fdop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c46925518.condition)
	e1:SetOperation(c46925518.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的结束阶段延迟效果注册到当前玩家，使该效果在本次结束阶段到来时生效。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：怪兽须为表侧表示，且当前可以变为里侧表示。
function c46925518.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 特殊召唤候选过滤：卡组中的卡须属于「鬼计」系列、等级不大于 lv（即本效果变成里侧守备表示的怪兽数量），且可由玩家 tp 以里侧守备表示进行特殊召唤。
function c46925518.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x8d) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 结束阶段延迟效果的发动条件：双方场上存在至少1张表侧表示且可以变为里侧表示的怪兽。
function c46925518.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张满足 filter 的怪兽（表侧且可变为里侧），存在则结束阶段效果可以发动。
	return Duel.IsExistingMatchingCard(c46925518.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 结束阶段延迟效果的处理：获取场上所有表侧且可变为里侧的怪兽，全部变为里侧守备表示，记录实际变化数量 ct；若自己主要怪兽区有空位，则从卡组选出1只等级不高于 ct 的「鬼计」怪兽；玩家选择同意后，将其中1只里侧守备表示特殊召唤；召唤成功时向对方展示那只卡。
function c46925518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足 filter 的怪兽（表侧且可变为里侧）作为对象组 g。
	local g=Duel.GetMatchingGroup(c46925518.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将 g 中所有怪兽变成里侧守备表示，返回实际改变了表示形式的怪兽数量 ct（作为可特殊召唤的「鬼计」怪兽等级上限）。
	local ct=Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	-- 若自己主要怪兽区没有可用空格，则不能进行从卡组的特殊召唤，直接终止本效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从自己卡组筛选出可特殊召唤的「鬼计」怪兽：属于「鬼计」、等级不高于 ct、可以里侧守备表示特殊召唤。
	local sg=Duel.GetMatchingGroup(c46925518.spfilter,tp,LOCATION_DECK,0,nil,e,tp,ct)
	-- 若存在符合条件的「鬼计」怪兽，则询问玩家是否要发动“那之后”的特殊召唤（选发）。
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(46925518,1)) then  --"是否要把「鬼计」怪兽从卡组里侧守备表示特殊召唤？"
		-- 中断当前效果连锁，让后续的特殊召唤作为独立处理进行，避免因连续处理而错过时点。
		Duel.BreakEffect()
		-- 给玩家显示选择提示：请选择要特殊召唤的卡（用于接下来的卡片选择界面）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		-- 将选择的卡以里侧守备表示特殊召唤到玩家 tp 的场上；若特殊召唤成功（返回值不为0），则继续后续确认动作。
		if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
			-- 将里侧守备表示特殊召唤成功的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
