--マジクリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：战斗或者对方的效果让自己受到伤害的回合的主要阶段以及战斗阶段，把这张卡从手卡送去墓地才能发动。从自己的卡组·墓地选1只「黑魔术师」或者「黑魔术少女」特殊召唤。这个效果在对方回合也能发动。
-- ②：自己场上的表侧表示的魔法师族怪兽被战斗或者对方的效果破坏的场合才能发动。墓地的这张卡加入手卡。
function c31699677.initial_effect(c)
	-- 给这张卡登记其效果文本中提及的「黑魔术师」(46986414)和「黑魔术少女」(38033121)的卡名，用于规则上正确关联这些卡名。
	aux.AddCodeList(c,46986414,38033121)
	-- 这个卡名的①②的效果1回合各能使用1次。①：战斗或者对方的效果让自己受到伤害的回合的主要阶段以及战斗阶段，把这张卡从手卡送去墓地才能发动。从自己的卡组·墓地选1只「黑魔术师」或者「黑魔术少女」特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31699677,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31699677)
	e1:SetCost(c31699677.spcost)
	e1:SetCondition(c31699677.spcon)
	e1:SetTarget(c31699677.sptg)
	e1:SetOperation(c31699677.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己场上的表侧表示的魔法师族怪兽被战斗或者对方的效果破坏的场合才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31699677,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31699676)
	e2:SetCondition(c31699677.thcon)
	e2:SetTarget(c31699677.thtg)
	e2:SetOperation(c31699677.thop)
	c:RegisterEffect(e2)
	if not c31699677.global_check then
		c31699677.global_check=true
		-- ①：战斗或者对方的效果让自己受到伤害的回合的主要阶段以及战斗阶段，把这张卡从手卡送去墓地才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c31699677.checkop)
		-- 将全局伤害检测效果注册到决斗中，使任意玩家受到伤害时都能触发checkop进行记录。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 伤害记录函数：当玩家因对方效果或战斗受到伤害时，为该受伤玩家设置本次回合内的伤害标记，用于①效果的发动条件判定。
function c31699677.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (bit.band(r,REASON_EFFECT)~=0 and rp==1-ep) or bit.band(r,REASON_BATTLE)~=0 then
		-- 为受到符合条件的伤害的玩家ep注册标记31699677，该标记持续到结束阶段重置，表示本回合已满足①效果的伤害条件。
		Duel.RegisterFlagEffect(ep,31699677,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ①效果的代价函数：确认这张卡自身可以从手卡送去墓地作为代价，然后执行送入墓地的动作。
function c31699677.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身从手卡送入墓地，作为发动①效果的COST。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果的发动条件：当前阶段为主要阶段或战斗阶段，且本回合已有符合条件的伤害标记。
function c31699677.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查本方是否拥有本回合受到过战斗或对方效果伤害的标记（flag数量≠0），以确认满足①效果的发动前提。
		and Duel.GetFlagEffect(tp,31699677)~=0
end
-- 特殊召唤对象过滤：选择卡名包含「黑魔术师」或「黑魔术少女」且能够被当前效果特殊召唤的怪兽。
function c31699677.spfilter(c,e,tp)
	return c:IsCode(46986414,38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标判定：自己场上存在可用怪兽区域，且卡组·墓地存在至少1只符合条件的「黑魔术师」或「黑魔术少女」。
function c31699677.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否存在可用的怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己的卡组·墓地是否存在至少1只满足spfilter条件的「黑魔术师」或「黑魔术少女」。
		and Duel.IsExistingMatchingCard(c31699677.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次特殊召唤的操作信息：从卡组·墓地特殊召唤1只怪兽，供相关卡牌进行连锁/时点判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：若自己场上仍有空位，则让玩家从卡组·墓地选择1只符合条件的怪兽（并排除王家长眠之谷影响）正面表示特殊召唤。
function c31699677.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的怪兽区域，若无则本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示消息：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自身卡组·墓地选择1只满足spfilter且不受王家长眠之谷影响的「黑魔术师」或「黑魔术少女」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31699677.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果破坏对象过滤：判定被破坏的怪兽为我方场上表侧表示的魔法师族怪兽，且破坏原因是战斗或对方发动的效果。
function c31699677.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousRaceOnField()&RACE_SPELLCASTER~=0 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②效果发动条件：本次被破坏的怪兽中不包含墓地中的这张卡自身，且存在至少1只符合cfilter条件的我方魔法师族怪兽被破坏。
function c31699677.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c31699677.cfilter,1,nil,tp)
end
-- ②效果目标判定：墓地中的这张卡自身可以加入手卡，并设置对应操作信息。
function c31699677.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将墓地中的这张卡加入手卡的操作信息，使相关效果能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果保持关联（未被无效或移动），则将其加入手卡。
function c31699677.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地中的这张卡加入其持有者的手卡（原因：效果）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
