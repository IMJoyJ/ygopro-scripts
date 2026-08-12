--極征竜－シャスマティス
-- 效果：
-- 龙族7星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，从卡组把1只7星「征龙」怪兽送去墓地，把这张卡1个超量素材取除才能发动。这个效果变成和从卡组送去墓地的那只怪兽的把自身从手卡丢弃发动的效果相同。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。自己的墓地·除外状态的1只7星「征龙」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加XYZ召唤手续，要求使用龙族7星怪兽作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- 效果①：自己·对方回合，从卡组把1只7星「征龙」怪兽送去墓地，把这张卡1个超量素材取除才能发动。这个效果变成和从卡组送去墓地的那只怪兽的把自身从手卡丢弃发动的效果相同。
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
	-- 效果②：这张卡被战斗或者对方的效果破坏的场合才能发动。自己的墓地·除外状态的1只7星「征龙」怪兽特殊召唤。
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
-- 过滤函数，用于筛选满足条件的7星「征龙」怪兽，且该怪兽具有可复制的手卡丢弃效果
function s.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x1c4) and c:IsLevel(7) and c:IsAbleToGraveAsCost()) then return false end
	local te=c.Dragon_Ruler_handes_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- 效果①的发动时处理函数，检查是否满足发动条件并选择目标怪兽进行效果复制
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
			-- 检查场上是否存在满足条件的7星「征龙」怪兽可用于效果复制
			and Duel.IsExistingMatchingCard(s.efffilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只怪兽并将其送入墓地
	local g=Duel.SelectMatchingCard(tp,s.efffilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local te=tc.Dragon_Ruler_handes_effect
	-- 将选中的怪兽送入墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	e:SetProperty(te:GetProperty())
	-- 清除当前连锁的目标卡片信息
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 效果①的发动后处理函数，执行复制的效果操作
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 效果②的发动条件判断函数，判断该卡是否因战斗或对方效果被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
end
-- 筛选可特殊召唤的7星「征龙」怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时处理函数，检查是否满足发动条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地或除外区是否存在满足条件的7星「征龙」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置效果②的操作信息，指定将要特殊召唤的卡的类型和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的发动后处理函数，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
