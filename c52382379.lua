--ネムレリアの夢喰い－レヴェイユ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把「梦见之妮穆蕾莉娅」以外的额外卡组3张卡里侧除外才能发动（这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤）。这张卡特殊召唤。
-- ②：从自己的手卡·场上（表侧表示）把这张卡以外的1只兽族·10星怪兽送去墓地才能发动。从卡组把1张「妮穆蕾莉娅」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片的效果：①效果在手卡·墓地特殊召唤，②效果在主要怪兽区域送墓手卡/场上的怪兽盖放陷阱，并添加用于特殊召唤限制的自定义计数器
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，把「梦见之妮穆蕾莉娅」以外的额外卡组3张卡里侧除外才能发动（这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤）。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上（表侧表示）把这张卡以外的1只兽族·10星怪兽送去墓地才能发动。从卡组把1张「妮穆蕾莉娅」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器，用于监视从额外卡组特殊召唤非表侧灵摆怪兽的行为
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数：非额外卡组召唤，或从额外卡组特殊召唤表侧表示的灵摆怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
-- 过滤函数：额外卡组中除「梦见之妮穆蕾莉娅」以外可以作为代价里侧除外的卡片
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost(POS_FACEDOWN) and not c:IsCode(70155677)
end
-- ①效果的发动代价（cost）：检查本回合是否未特殊召唤过非灵摆怪兽，且额外卡组中是否存在3张符合条件的卡用于里侧除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果进行发动检查，首先确认本回合是否没有从额外卡组特殊召唤过非灵摆怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		-- 其次确认自己的额外卡组中是否存在至少3张「梦见之妮穆蕾莉娅」以外的卡片
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_EXTRA,0,3,nil) end
	-- ①：这张卡在手卡·墓地存在的场合，把「梦见之妮穆蕾莉娅」以外的额外卡组3张卡里侧除外才能发动（这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤）。这张卡特殊召唤。②：从自己的手卡·场上（表侧表示）把这张卡以外的1只兽族·10星怪兽送去墓地才能发动。从卡组把1张「妮穆蕾莉娅」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册特殊召唤限制效果给玩家，使其本回合不能从额外卡组特殊召唤非灵摆怪兽
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要里侧除外的额外卡组卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的额外卡组中选择3张除「梦见之妮穆蕾莉娅」以外的卡片
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_EXTRA,0,3,3,nil)
	-- 将所选的额外卡组卡片里侧除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 限制特殊召唤从额外卡组出场且非灵摆怪兽的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_PENDULUM)
end
-- ①效果的靶向/发动检查（target）：确认主怪兽区域有空位且自身可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 如果进行发动检查，确认自己场上有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置特殊召唤的操作信息，表明该效果将特殊召唤1张卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理（operation）：如果此卡仍与效果关联，则将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：手卡或场上表侧表示的可以送去墓地的兽族·10星怪兽
function s.tgfilter(c)
	return c:IsLevel(10) and c:IsRace(RACE_BEAST) and c:IsAbleToGraveAsCost() and c:IsFaceupEx()
end
-- ②效果的发动代价（cost）：从自己手卡或场上（表侧表示）将除自身外的一只兽族·10星怪兽送去墓地
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 如果进行发动检查，确认自己手卡或场上是否存在符合条件的可送去墓地的兽族·10星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己手卡或场上（表侧表示）除自身外的1只兽族·10星怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
	-- 将所选的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：卡组中可以盖放到场上的「妮穆蕾莉娅」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x191) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的靶向/发动检查（target）：确认卡组中存在可以盖放的的「妮穆蕾莉娅」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果进行发动检查，确认卡组中是否存在符合条件的「妮穆蕾莉娅」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的效果处理（operation）：从卡组选择一张「妮穆蕾莉娅」陷阱卡在场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择一张符合条件的「妮穆蕾莉娅」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的陷阱卡在自己的场上盖放
		Duel.SSet(tp,g)
	end
end
