--禁呪アラマティア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。在自己或者对方场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。那之后，选自己1张手卡送去墓地。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。
-- ②：自己场上的怪兽被战斗·效果破坏的场合才能发动。在自己或者对方场上把1只「勇者衍生物」特殊召唤。
function c34690953.initial_effect(c)
	-- 将「勇者衍生物」(3285552)登记到本卡的记述卡名列表中，使后续可以用aux.IsCodeOrListed判断怪兽是否为本卡效果记述的「勇者衍生物」或其相关怪兽。
	aux.AddCodeList(c,3285552)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。在自己或者对方场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。那之后，选自己1张手卡送去墓地。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34690953,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,34690953)
	e2:SetCost(c34690953.tkcost)
	e2:SetTarget(c34690953.tktg)
	e2:SetOperation(c34690953.tkop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己场上的怪兽被战斗·效果破坏的场合才能发动。在自己或者对方场上把1只「勇者衍生物」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34690953,1))  --"特殊召唤衍生物"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,34690954)
	e3:SetCondition(c34690953.spcon)
	e3:SetTarget(c34690953.sptg)
	e3:SetOperation(c34690953.spop)
	c:RegisterEffect(e3)
	-- 注册一个代号为34690953的特殊召唤活动计数器，该计数器会把特殊召唤时不符合counterfilter过滤条件的召唤行为计数，用于①效果发动前检查本回合是否已经特殊召唤过违规怪兽。
	Duel.AddCustomActivityCounter(34690953,ACTIVITY_SPSUMMON,c34690953.counterfilter)
end
-- 定义counterfilter：判断一张卡是否属于「勇者衍生物」或效果文本中记述了「勇者衍生物」之名的怪兽；返回真表示该卡属于本效果允许的特殊召唤对象，返回假则会被上述特殊召唤计数器记为违规。
function c34690953.counterfilter(c)
	-- 判断卡片c是否为卡号3285552的「勇者衍生物」，或者其卡名是否被记载在c的效果文本中。
	return aux.IsCodeOrListed(c,3285552)
end
-- ①效果的发动代价函数：先确认本回合没有发生过非允许怪兽的特殊召唤，然后给tp附加一个誓约性质的自肃效果，使本回合内不能特殊召唤不符合counterfilter的怪兽。
function c34690953.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检查阶段，确认本回合tp的特殊召唤活动计数为0，即尚未特殊召唤过非「勇者衍生物」/未记述该衍生物名的怪兽，作为①效果的发动前提。
	if chk==0 then return Duel.GetCustomActivityCount(34690953,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。在自己或者对方场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。那之后，选自己1张手卡送去墓地。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。②：自己场上的怪兽被战斗·效果破坏的场合才能发动。在自己或者对方场上把1只「勇者衍生物」特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34690953.splimit)
	-- 将刚创建的“不能特殊召唤非允许怪兽”的限制效果e1注册给玩家tp，使其在本回合结束前对tp生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃过滤函数：如果某张怪兽不能通过counterfilter判定（即不是「勇者衍生物」或未记述其名的怪兽），则禁止将其特殊召唤。
function c34690953.splimit(e,c)
	return not c34690953.counterfilter(c)
end
-- ①效果的发动目标函数：检查自己或对方场上是否存在可特殊召唤「勇者衍生物」的空位，且自己手牌有至少1张可以送去墓地的卡；满足则设定特殊召唤衍生物及送墓的操作信息。
function c34690953.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格，用于把衍生物特殊召唤到自己场上。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认tp能够在自己场上以表侧表示特殊召唤1只「勇者衍生物」（天使族·地·4星·攻/守2000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有可用的怪兽区空格，用于把衍生物特殊召唤到对方场上。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 确认tp能够把1只「勇者衍生物」以表侧表示特殊召唤到对方（1-tp）场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	if chk==0 then return (b1 or b2)
		-- 确认tp手牌中存在至少1张能够送去墓地的卡，以满足“选自己1张手卡送去墓地”的条件。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	-- 设置本效果的处理信息包含CATEGORY_TOKEN，表明预定生成衍生物（供衍生物相关卡或效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本效果的处理信息包含CATEGORY_SPECIAL_SUMMON，表明预定进行1次特殊召唤，目标玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ①效果的处理函数：根据双方场地情况选择（或自动确定）将衍生物特殊召唤到自己或对方场上；若特招成功，则选择自己1张手卡送去墓地。
function c34690953.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区空格。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认tp可以在自己场上表侧表示特殊召唤1只「勇者衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有可用的怪兽区空格。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 确认tp可以把1只「勇者衍生物」表侧表示特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	local sel=0
	if b1 or b2 then
		if b1 and b2 then
			-- 当自己和对方案场都能特招时，让tp选择将衍生物特殊召唤到自己场上还是对方场上，sel=0表示自己，sel=1表示对方。
			sel=Duel.SelectOption(tp,aux.Stringid(34690953,2),aux.Stringid(34690953,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
		elseif b2 then
			sel=1
		end
		local to=tp
		if sel==1 then to=1-tp end
		-- 创建1只「勇者衍生物」衍生物（卡号34690954），其拥有者为tp。
		local token=Duel.CreateToken(tp,34690954)
		-- 将衍生物以表侧表示特殊召唤到选定玩家to的场上；如果特殊召唤成功（返回值大于0），则继续执行后面的送墓处理。
		if Duel.SpecialSummon(token,0,tp,to,false,false,POS_FACEUP)>0 then
			-- 向tp显示“请选择要送去墓地的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从tp手卡中选择1张可以送去墓地的卡（作为“那之后”送去墓地的对象）。
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				-- 中断当前效果链，使衍生物特殊召唤与该手卡送墓的处理视为不同时处理，避免因同时处理而错过时点。
				Duel.BreakEffect()
				-- 将刚才选择的手卡以效果原因送进墓地，完成①效果后续的送墓处理。
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
-- 定义②效果的破坏过滤函数：判断怪兽是否因战斗或效果被破坏，且破坏前位于主要怪兽区、控制者是tp（即“自己场上的怪兽被战斗·效果破坏”）。
function c34690953.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：被破坏的怪兽集合eg中存在至少1只满足cfilter的怪兽。
function c34690953.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34690953.cfilter,1,nil,tp)
end
-- ②效果的发动目标函数：检查自己或对方场上是否有可用的怪兽区空格并能特殊召唤「勇者衍生物」，满足则设定特殊召唤衍生物的操作信息。
function c34690953.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认tp可以在自己场上表侧表示特殊召唤1只「勇者衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有可用的怪兽区空格。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 确认tp可以把1只「勇者衍生物」表侧表示特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	if chk==0 then return b1 or b2 end
	-- 设置本效果的处理信息包含CATEGORY_TOKEN，表明预定生成衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本效果的处理信息包含CATEGORY_SPECIAL_SUMMON，表明预定特殊召唤1只衍生物，目标玩家可为任意一方（PLAYER_ALL）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,0)
end
-- ②效果的处理函数：根据场况选择（或自动确定）将1只「勇者衍生物」特殊召唤到自己或对方场上。
function c34690953.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区空格。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认tp可以在自己场上表侧表示特殊召唤1只「勇者衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有可用的怪兽区空格。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 确认tp可以把1只「勇者衍生物」表侧表示特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	local sel=0
	if b1 or b2 then
		if b1 and b2 then
			-- 当双方场地都能特招时，让tp选择将衍生物特殊召唤到自己场上还是对方场上。
			sel=Duel.SelectOption(tp,aux.Stringid(34690953,2),aux.Stringid(34690953,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
		elseif b2 then
			sel=1
		end
		local to=tp
		if sel==1 then to=1-tp end
		-- 创建1只「勇者衍生物」衍生物。
		local token=Duel.CreateToken(tp,34690954)
		-- 将衍生物以表侧表示特殊召唤到选定玩家to的场上，完成②效果的特招。
		Duel.SpecialSummon(token,0,tp,to,false,false,POS_FACEUP)
	end
end
