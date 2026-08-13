--極征竜－シャスマティス
-- 效果：
-- 龙族7星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，从卡组把1只7星「征龙」怪兽送去墓地，把这张卡1个超量素材取除才能发动。这个效果变成和从卡组送去墓地的那只怪兽的把自身从手卡丢弃发动的效果相同。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。自己的墓地·除外状态的1只7星「征龙」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的基本效果：赋予龙族7星怪兽×2的超量召唤手续并解除苏生限制，然后注册①的诱发即时效果（复制效果）和②的诱发选发效果（特殊召唤）。
function s.initial_effect(c)
	-- 给这张卡添加超量召唤手续：可用龙族7星怪兽2只作为超量素材来超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- ①效果：自己·对方回合，从卡组把1只7星「征龙」怪兽送去墓地，把这张卡1个超量素材取除才能发动。这个效果变成和从卡组送去墓地的那只怪兽的把自身从手卡丢弃发动的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"复制效果"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
	-- ②效果：这张卡被战斗或者对方的效果破坏的场合才能发动。自己的墓地·除外状态的1只7星「征龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义复制对象的筛选条件：卡组中满足7星·「征龙」、可作为代价送去墓地，且存在可复制的“把手卡丢弃发动”的效果，并确认该效果在当前时点可以发动。
function s.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x1c4) and c:IsLevel(7) and c:IsAbleToGraveAsCost()) then return false end
	local te=c.Dragon_Ruler_handes_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- 复制效果的发动处理：先检测是否满足代价与对象条件；发动时选择卡组1只符合条件的7星「征龙」怪兽送去墓地、取除1个超量素材，并用该怪兽的丢弃手卡发动效果来替换本效果的属性、目标与操作。
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
			-- 检查卡组中是否存在至少1张满足s.efffilter条件的7星「征龙」怪兽，用于判定这个效果能否发动。
			and Duel.IsExistingMatchingCard(s.efffilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	-- 给玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足s.efffilter条件的7星「征龙」怪兽，该选择将作为发动代价送去墓地。
	local g=Duel.SelectMatchingCard(tp,s.efffilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local te=tc.Dragon_Ruler_handes_effect
	-- 将选中的那只7星「征龙」怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	e:SetProperty(te:GetProperty())
	-- 清除当前连锁上已有的对象信息，避免复制效果时继承不相关的对象。
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，使被复制效果不会被错误的响应检测所干扰。
	Duel.ClearOperationInfo(0)
end
-- 执行复制到的效果：从当前效果的LabelObject中取出被复制怪兽的丢弃手卡发动效果，并以当前效果的身份执行其处理函数。
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- ②效果的发动条件：这张卡被战斗破坏，或被对方玩家的效果破坏且破坏前是己方场上的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
end
-- 筛选可以特殊召唤的7星「征龙」怪兽：表侧表示、属于「征龙」、等级7，且能够被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标判定：自己场上存在可用的主要怪兽区，且墓地或除外区存在至少1只符合条件的7星「征龙」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域，用于确认能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地·除外状态是否存在至少1只满足s.spfilter条件的7星「征龙」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，表明本效果将进行特殊召唤，对象来自墓地·除外区，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理：若自己场上仍有空位，则从墓地·除外状态选择1只不受王家长眠之谷影响的7星「征龙」怪兽表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地和除外区选择1只满足s.spfilter且不受王家长眠之谷影响的7星「征龙」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的7星「征龙」怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
