--戦華の孟－曹徳
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方场上的卡被战斗·效果破坏的场合，把这张卡以外的自己的手卡·场上1张卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：只要自己场上有其他的「战华」怪兽存在，这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。
function c33545259.initial_effect(c)
	-- ①：对方场上的卡被战斗·效果破坏的场合，把这张卡以外的自己的手卡·场上1张卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33545259,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+33545259)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,33545259)
	e1:SetCondition(c33545259.spcon1)
	e1:SetCost(c33545259.spcost1)
	e1:SetTarget(c33545259.sptg1)
	e1:SetOperation(c33545259.spop1)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有其他的「战华」怪兽存在，这张卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33545259.tgcon)
	-- 设置“不能成为对方效果对象”的判定函数：只有对方发动的效果无法选择此卡（效果发动者不是此卡的控制者时为不可选择）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置“不会被对方效果破坏”的判定函数：对方发动的效果无法将此卡破坏（效果发动者为此卡控制者的对方时不可破坏）。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33545259,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCountLimit(1,33545260)
	-- 设置③效果的发动条件：此卡与对方怪兽战斗并将其战斗破坏送去墓地，且此卡与战斗相关（满足 aux.bdogcon 的战斗破坏判定）。
	e4:SetCondition(aux.bdogcon)
	e4:SetTarget(c33545259.sptg2)
	e4:SetOperation(c33545259.spop2)
	c:RegisterEffect(e4)
	if not c33545259.global_check then
		c33545259.global_check=true
		-- ①：对方场上的卡被战斗·效果破坏的场合（本段为全局监听：当场上存在被战斗或效果破坏的卡时，触发后续自定义事件，以支持①效果的发动检测）。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c33545259.regcon)
		ge1:SetOperation(c33545259.regop)
		-- 将全局监听效果 ge1 注册到整个决斗环境中（由玩家0持有），使其持续监听场上卡片被破坏的时点。
		Duel.RegisterEffect(ge1,0)
	end
end
-- regfilter 过滤函数：判断被破坏的卡是否因战斗或效果而被破坏，并且破坏前控制者是 tp、破坏前位于场上（即用于判定“对方场上的卡被战斗·效果破坏”）。
function c33545259.regfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- regcon 条件函数：检查本次被破坏的卡组 eg 中是否存在原本属于玩家0和/或玩家1场上且因战斗/效果被破坏的卡，将“哪一方场上的卡被破坏”编码到 e 的标签（0=玩家0，1=玩家1，PLAYER_ALL=双方），存在则返回 true。
function c33545259.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c33545259.regfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c33545259.regfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- regop 操作函数：在满足条件时，以本次被破坏的卡组 eg 为对象，触发自定义事件 EVENT_CUSTOM+33545259，并把 e 标签中记录的破坏方信息作为事件参数 ev 传递出去。
function c33545259.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 用 Duel.RaiseEvent 触发自定义事件，把被破坏的卡组 eg 和“破坏方信息”传给所有监听 EVENT_CUSTOM+33545259 的效果，供①效果判断时点使用。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+33545259,re,r,rp,ep,e:GetLabel())
end
-- spcon1 条件函数：①效果的发动条件——自定义事件参数 ev 表示被破坏的卡的原控制者，只有该控制者是对方（1-tp）或双方（PLAYER_ALL）时，才符合“对方场上的卡被破坏”的发动时点。
function c33545259.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return ev==1-tp or ev==PLAYER_ALL
end
-- costfilter 过滤函数：选择①效果代价的卡——能作为代价送去墓地，并且将该卡送墓后自己场上仍有可用的怪兽区空格，从而保证之后能特殊召唤此卡。
function c33545259.costfilter(c,tp)
	-- 判断候选卡可被作为代价送入墓地，且其离开后我方仍有怪兽区空格，即满足代价支付与后续特殊召唤的空间条件。
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- spcost1 代价函数：从自己的手卡·场上选择除自身外的1张符合 costfilter 的卡送去墓地，作为①效果的发动代价。
function c33545259.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在代价合法性检查中，判断自己的手卡·场上是否存在满足条件的卡（可作代价送墓且送墓后有空位），存在才能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c33545259.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	-- 发送选择提示，让玩家从手卡·场上选择要送去墓地的卡（提示文字为“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·场上选择1张符合代价条件的卡（排除自身），作为①效果发动要送去墓地的代价卡。
	local g=Duel.SelectMatchingCard(tp,c33545259.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	-- 将选中的代价卡以“代价（REASON_COST）”的原因送去墓地，完成①效果的费用支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- sptg1 目标函数：①效果的目标处理——确认此卡自身可以被特殊召唤，并设置本次操作包含特殊召唤此卡的信息。
function c33545259.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：本次效果将执行特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为此卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- spop1 操作函数：①效果处理时，如果此卡仍与当前效果关联（未被无效、未离场），将其从手卡特殊召唤。
function c33545259.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到其控制者的场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- cfilter 过滤函数：筛选出表侧表示且卡名含有「战华」字段的怪兽，用于②效果的“其他战华怪兽存在”条件。
function c33545259.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- tgcon 条件函数：②效果的适用条件——自己场上存在这张卡以外的表侧表示「战华」怪兽。
function c33545259.tgcon(e)
	-- 检查自己怪兽区是否存在1张表侧表示且是「战华」字段的怪兽，且不包括这张卡自身，以此作为②效果的条件。
	return Duel.IsExistingMatchingCard(c33545259.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- sptg2 目标函数：③效果的目标处理——获取战斗破坏的对方怪兽，确认自己场上有空位且该怪兽能够被特殊召唤，并将它设为目标。
function c33545259.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 发动③效果时检查自己场上是否有可用的怪兽区空格，以便放置要特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 把战斗破坏的对方怪兽设置为当前效果的对象，使其在效果处理时与效果建立关联。
	Duel.SetTargetCard(bc)
	-- 设置当前连锁的操作信息：本次效果将特殊召唤（CATEGORY_SPECIAL_SUMMON）目标怪兽 bc，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- spop2 操作函数：③效果处理时，若目标怪兽仍与效果关联，则将其特殊召唤到自己场上。
function c33545259.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果发动时设置的唯一目标怪兽（战斗破坏送去墓地的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该目标怪兽以表侧守备表示特殊召唤到自己场上，不检查召唤条件、不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
