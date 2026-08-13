--ミミグル・アーマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。对方场上有怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●这个回合中，「迷拟宝箱鬼」怪兽不会被战斗破坏。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 初始化该卡的效果：分别注册反转诱发效果e1和手卡起动效果e2，e1对应②的反转效果，e2对应①的特殊召唤效果，并为其设置描述、分类、类型、条件、目标与操作函数。
function s.initial_effect(c)
	-- ②的效果：这张卡在主要阶段反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 设置反转效果的发动条件：只能在自己或对方玩家的主要阶段且该卡反转时才能发动（由辅助函数aux.MimighoulFlipCondition判定）。
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①的效果：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。对方场上有怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ②效果的发动合法性判定：无条件通过；由于效果处理时会变更控制权，因此向系统登记本次操作涉及控制权变更。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本连锁的处理信息：类别为改变控制权，对象为本卡，数量为1，归属玩家未知，位置未知。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- ②效果处理：先给对方场上表侧表示的所有「迷拟宝箱鬼」怪兽赋予本回合内不会被战斗破坏的效果，然后若本卡仍与效果关联，则中断连锁处理并将本卡的控制权移给对方。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ②的效果：这张卡在主要阶段反转的场合发动。以下效果各适用。●这个回合中，「迷拟宝箱鬼」怪兽不会被战斗破坏。●这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	-- 将“不会被战斗破坏”的永续效果注册到当前操作者tp的场上，效果持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续的控制权转移作为独立处理的时点，避免与上述保护效果同时处理。
		Duel.BreakEffect()
		-- 将本卡（c）的控制权转移给对方玩家（1-tp）。
		Duel.GetControl(c,1-tp)
	end
end
-- 指定“不会被战斗破坏”效果的适用对象：持有「迷拟宝箱鬼」字段（SetCard 0x1b7）的怪兽。
function s.ptfilter(e,c)
	return c:IsSetCard(0x1b7)
end
-- 判断这张卡能否在自己场上表侧表示特殊召唤：需要对方场上有怪兽存在，并且本卡满足表侧表示特殊召唤的条件（不考虑召唤条件和苏生限制）。
function s.sspfilter(c,tp,e)
	-- 检查对方场上是否存在至少1只怪兽（用于决定是否可以选择在自己场上特殊召唤）。
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 判断这张卡能否在对方场上里侧守备表示特殊召唤：需要满足以里侧守备表示特殊召唤到对方场上的条件（不考虑召唤条件和苏生限制）。
function s.ospfilter(c,tp,e)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
-- ①效果发动合法性判定：在自己场上表侧表示特殊召唤（需对方场上有怪兽且自己主怪兽区有空位）或在对方场上里侧守备表示特殊召唤（需对方主怪兽区有空位）两种方案中至少有一种可行。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 方案1：本卡可以表侧表示特殊召唤到自己场上，且自己主怪兽区有空位。
	if chk==0 then return s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 方案2：本卡可以里侧守备表示特殊召唤到对方场上，且对方主怪兽区有空位。
		or s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 向系统登记本连锁的处理信息：类别为特殊召唤，对象为本卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：先确认本卡仍与效果关联且至少一种特殊召唤方案仍可行；然后计算两种方案的可行性；让玩家选择召唤到哪边；若选自己场上则表侧守备表示特殊召唤（实际为表侧表示），若选对方场上则里侧守备表示特殊召唤并给对方确认；若两边都没有空位则按规则送入墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not s.sspfilter(c,tp,e) and not s.ospfilter(c,tp,e)) then return end
	-- 计算方案1可行性：本卡在自己场上表侧表示特殊召唤可行，且自己主怪兽区有空位。
	local b1=s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 计算方案2可行性：本卡在对方场上里侧守备表示特殊召唤可行，且对方主怪兽区有空位。
	local b2=s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	-- 让当前玩家从可行方案中选择特殊召唤的目标场地，选项分别对应自己场上和对方场上。
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),tp},  --"在自己场上特殊召唤"
		{b2,aux.Stringid(id,3),1-tp})  --"在对方场上特殊召唤"
	if toplayer==tp then
		-- 在自己场上以表侧表示特殊召唤本卡。
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	elseif toplayer==1-tp then
		-- 在对方场上以里侧守备表示特殊召唤本卡。
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将里侧守备表示特殊召唤到对方场上的本卡展示给当前玩家确认（用于确认其里侧表示的怪兽卡）。
		Duel.ConfirmCards(tp,c)
	else
		-- 失败处理检测：如果自己场上和对方场上都没有可供特殊召唤的主怪兽区空格，则无法进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 因双方主怪兽区均无空位，按规则将本卡送入墓地。
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
