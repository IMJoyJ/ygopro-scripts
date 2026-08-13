--DDD怒濤王シーザー
-- 效果：
-- 恶魔族4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡1个超量素材取除才能发动。这个回合的战斗阶段结束时，这个回合被破坏的怪兽从自己墓地尽可能特殊召唤。下个回合的准备阶段，自己受到这个效果特殊召唤的怪兽数量×1000伤害。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
function c3758046.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只恶魔族4星怪兽为素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡1个超量素材取除才能发动。这个回合的战斗阶段结束时，这个回合被破坏的怪兽从自己墓地尽可能特殊召唤。下个回合的准备阶段，自己受到这个效果特殊召唤的怪兽数量×1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3758046,0))  --"这个回合被破坏的怪兽在战斗阶段结束时特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3758046)
	-- 设置①效果的发动条件：仅限自己或对方的战斗阶段中（含战斗阶段开始到结束）才能发动。
	e1:SetCondition(aux.bpcon)
	e1:SetCost(c3758046.cost)
	e1:SetOperation(c3758046.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3758046,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,3758047)
	e2:SetCondition(c3758046.thcon)
	e2:SetTarget(c3758046.thtg)
	e2:SetOperation(c3758046.thop)
	c:RegisterEffect(e2)
end
-- 代价处理：发动前检查自己场上这张卡是否有至少1个超量素材可移除；发动时移除这张卡的1个超量素材作为代价。
function c3758046.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：注册一个在战斗阶段结束时触发的持续效果，用于在该时点执行特殊召唤（真正的特殊召唤逻辑在spop中实现）。
function c3758046.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的战斗阶段结束时，这个回合被破坏的怪兽从自己墓地尽可能特殊召唤。下个回合的准备阶段，自己受到这个效果特殊召唤的怪兽数量×1000伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetCountLimit(1)
	e1:SetOperation(c3758046.spop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述持续效果注册到当前玩家（tp）的场上，使其能在战斗阶段结束时生效。
	Duel.RegisterEffect(e1,tp)
end
-- 筛选条件：该怪兽是本回合（以当前回合数判断）被破坏送去墓地，并且可以被当前玩家用效果特殊召唤。
function c3758046.filter(c,e,tp,id)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==id and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 战斗阶段结束时的特殊召唤处理：计算可用怪兽区域空格数，获取符合条件的墓地怪兽；若数量超过空格则从中选择等于空格数的怪兽，否则全部特殊召唤；特殊召唤成功后注册下个准备阶段造成伤害的效果。
function c3758046.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区域当前可用的空格数量，用于决定最多能特殊召唤多少只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地中满足条件（本回合被破坏且可特殊召唤，且不受王家长眠之谷影响）的怪兽集合。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c3758046.filter),tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local g=nil
	if tg:GetCount()>ft then
		-- 当可选怪兽数量超过可用空格时，提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 下个回合的准备阶段，自己受到这个效果特殊召唤的怪兽数量×1000伤害。②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(3758046,2))  --"受到伤害"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(g:GetCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetOperation(c3758046.damop)
		-- 将下个准备阶段造成伤害的持续效果注册到当前玩家（tp）的场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害处理：给予自己LP伤害，数值为e:GetLabel()记录的先前特殊召唤的怪兽数量×1000。
function c3758046.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行伤害：对当前玩家造成所记录数量×1000的效果伤害。
	Duel.Damage(tp,e:GetLabel()*1000,REASON_EFFECT)
end
-- ②效果的发动条件：这张卡是从场上（LOCATION_ONFIELD）送去墓地，避免从手牌/卡组等地方送去墓地时误发。
function c3758046.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的检索过滤：卡名属于「契约书」（setcode 0xae）且能够加入手卡的卡。
function c3758046.thfilter(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end
-- ②效果的目标检查与操作信息：确认卡组存在至少1张符合条件的「契约书」卡；设置本次效果处理为从卡组把1张卡加入手卡。
function c3758046.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：卡组中是否存在至少1张符合条件的「契约书」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c3758046.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将1张卡从卡组加入手卡（用于给其他卡/效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「契约书」卡加入手卡，并向对方展示确认。
function c3758046.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家从卡组选择1张要加入手卡的「契约书」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张符合条件的「契约书」卡（过滤条件由c3758046.thfilter决定）。
	local g=Duel.SelectMatchingCard(tp,c3758046.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
