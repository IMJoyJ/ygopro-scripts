--マシンナーズ・ルインフォース
-- 效果：
-- 这张卡不能通常召唤。把等级合计直到12以上的自己墓地的机械族怪兽除外的场合才能从墓地特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：战斗阶段对方把效果发动时，把基本分支付一半才能发动。那个发动无效，对方基本分变成一半。
-- ②：这张卡被战斗·效果破坏的场合才能发动。等级合计最多到12星以下为止，选除外的最多3只自己的「机甲」怪兽特殊召唤。
function c46033517.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把等级合计直到12以上的自己墓地的机械族怪兽除外的场合才能从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c46033517.hspcon)
	e2:SetTarget(c46033517.hsptg)
	e2:SetOperation(c46033517.hspop)
	c:RegisterEffect(e2)
	-- ①：战斗阶段对方把效果发动时，把基本分支付一半才能发动。那个发动无效，对方基本分变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46033517,0))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,46033517)
	e3:SetCost(c46033517.negcost)
	e3:SetCondition(c46033517.negcon)
	e3:SetTarget(c46033517.negtg)
	e3:SetOperation(c46033517.negop)
	c:RegisterEffect(e3)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。等级合计最多到12星以下为止，选除外的最多3只自己的「机甲」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46033517,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,46033518)
	e4:SetCondition(c46033517.spcon)
	e4:SetTarget(c46033517.sptg)
	e4:SetOperation(c46033517.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数：筛选可作为从墓地特殊召唤代价的卡片——必须是机械族、等级1以上的怪兽卡，并且可以被除外作为代价。
function c46033517.hspfilter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 候选组合法性判定函数：将候选组设为已选卡片，并检查其等级合计是否达到12以上，以满足特殊召唤所需的除外代价条件。
function c46033517.hspcheck(g)
	-- 将当前候选组标记为已选择的卡片，供后续 CheckWithSumGreater 进行等级合计判定。
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,12)
end
-- 辅助检查函数：若当前所选卡片的等级合计未超过12则允许继续选择；若已超过12，则标记已选卡并判定合计仍满足至少12以上的条件，用于在选卡过程中控制可选状态。
function c46033517.hspgcheck(g)
	if g:GetSum(Card.GetLevel)<=12 then return true end
	-- 将当前候选组标记为已选择的卡片，供后续 CheckWithSumGreater 进行等级合计判定。
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,12)
end
-- 特殊召唤手续的条件：若c为空则按惯例通过；否则确认该卡控制者主怪兽区有空位，并在墓地中检索所有可作为代价的机械族怪兽，检查是否存在一个非空子集的等级合计能达到12以上。
function c46033517.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取该玩家主怪兽区的空位数量，若没有空位则无法进行特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	-- 取得自己墓地中除这张卡以外、满足代价过滤条件（机械族、等级1以上、可除外）的全部怪兽组。
	local g=Duel.GetMatchingGroup(c46033517.hspfilter,tp,LOCATION_GRAVE,0,c)
	-- 设置额外的子组检查函数，使后续的 CheckSubGroup/SelectSubGroup 在搜索/选择时按照 hspgcheck 的等级合计条件进行限制。
	aux.GCheckAdditional=c46033517.hspgcheck
	local res=g:CheckSubGroup(c46033517.hspcheck,1,#g)
	-- 清除额外的子组检查函数，避免影响后续其他选择操作。
	aux.GCheckAdditional=nil
	return res
end
-- 特殊召唤手续的选牌阶段：让玩家从满足除外代价的墓地机械族怪兽中选择等级合计至少12以上的一个子组，保存该子组到效果标签中，作为召唤时实际除外的对象；若未成功选择则无法发动。
function c46033517.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己墓地中除这张卡以外、满足代价过滤条件（机械族、等级1以上、可除外）的全部怪兽组。
	local g=Duel.GetMatchingGroup(c46033517.hspfilter,tp,LOCATION_GRAVE,0,c)
	-- 弹出选择提示，要求玩家选择要除外的卡片（提示文本为「请选择要除外的卡」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置额外的子组检查函数，使后续的 CheckSubGroup/SelectSubGroup 在搜索/选择时按照 hspgcheck 的等级合计条件进行限制。
	aux.GCheckAdditional=c46033517.hspgcheck
	local sg=g:SelectSubGroup(tp,c46033517.hspcheck,true,1,#g)
	-- 清除额外的子组检查函数，避免影响后续其他选择操作。
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：从效果标签中取出玩家选定的除外对象组，将其表侧除外，作为从墓地特殊召唤的代价，然后释放临时保存的组对象。
function c46033517.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选定的一组机械族怪兽表侧表示除外（除外原因是特殊召唤手续的代价）。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- ①效果的发动代价：只要连锁合法，支付当前LP的一半（向下取整）作为COST。
function c46033517.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 实际扣除操作玩家一半LP作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ①效果的发动条件：必须处于战斗阶段（从战斗阶段开始到战斗阶段结束之间）、这张卡未被战斗破坏、对方的效果正在发动且该发动可以被无效；同时连锁的发动者必须为对方。
function c46033517.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段存入ph，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	-- 返回条件判断结果：这张卡未被战斗破坏、该连锁可被无效且是对方发动的效果，满足这些条件才能发动①。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- ①效果发动时的目标处理：不取对象，但需要把被无效的对象设置进操作信息，声明本连锁将进行「发动无效」处理。
function c46033517.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置此次连锁的操作信息：效果分类为「无效发动」，对象为对方发动的那个效果所在的事件（eg），数量为1，供后续检测与处理使用。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①效果的处理：先尝试无效对方的效果发动；如果成功，则将对方基本分变为当前LP的一半（向上取整）。
function c46033517.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，只有无效成功时才执行后续的LP减半处理。
	if Duel.NegateActivation(ev) then
		-- 把对方玩家的基本分设置为原来的一半（向上取整）。
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
-- ②效果的发动条件：这张卡被战斗破坏或效果破坏时（破坏原因中包含战斗或效果）满足。
function c46033517.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- ②特殊召唤对象的过滤条件：卡名属于「机甲」字段、等级1以上，并且能够被该效果特殊召唤。
function c46033517.spfilter(c,e,tp)
	return c:IsSetCard(0x36) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的目标检测：若自己主怪兽区有空位，并且除外区存在至少1只满足特殊召唤条件的「机甲」怪兽，则效果可以发动；并设置特殊召唤的操作信息。
function c46033517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：确认自己主怪兽区有空位可用来特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认除外区存在至少1只可特殊召唤的「机甲」怪兽。
		and Duel.IsExistingMatchingCard(c46033517.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本效果含有从除外区特殊召唤怪兽，数量预计为1，位置为除外区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 额外限制函数：用于检查当前选择的特殊召唤对象组的等级合计是否不超过12，以满足②效果「等级合计最多到12星以下」的限制。
function c46033517.spcheck(g)
	return g:GetSum(Card.GetLevel)<=12
end
-- ②效果处理：计算可特殊召唤数量（最多3只且不超过空位），取得除外区所有符合条件的「机甲」怪兽；若存在青眼精灵龙效果导致不能同时特殊召唤2只以上，则上限降为1；提示玩家选择1到上限只怪兽，所选怪兽的等级合计不超过12；最后将这些怪兽表侧表示特殊召唤到自己场上。
function c46033517.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算实际可特殊召唤的最大数量：取主怪兽区空位与3的较小值。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 收集除外区中所有满足「机甲」字段、等级1以上且可被该效果特殊召唤的怪兽，作为可选的召唤对象组。
	local tg=Duel.GetMatchingGroup(c46033517.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡片（提示文本为「请选择要特殊召唤的卡」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置额外的选择限制函数，使玩家选择特殊召唤对象时，所选怪兽的等级合计不能超过12。
	aux.GCheckAdditional=c46033517.spcheck
	-- 让玩家从可选怪兽中选择1到ft只怪兽作为本次特殊召唤的对象；选择过程受额外的等级合计≤12限制。
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
	-- 清除额外的选择限制函数。
	aux.GCheckAdditional=nil
	-- 将玩家选出的所有「机甲」怪兽以表侧攻击表示特殊召唤到该玩家场上，且本次特殊召唤不视为因召唤手续而受到额外限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
