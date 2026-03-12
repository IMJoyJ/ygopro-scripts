--ネムレリアの夢喰い－レヴェイユ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把「梦见之妮穆蕾莉娅」以外的额外卡组3张卡里侧除外才能发动（这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤）。这张卡特殊召唤。
-- ②：从自己的手卡·场上（表侧表示）把这张卡以外的1只兽族·10星怪兽送去墓地才能发动。从卡组把1张「妮穆蕾莉娅」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①效果为手卡/墓地时可特殊召唤，②效果为场上的兽族10星怪兽送去墓地可盖放妮穆蕾莉娅陷阱
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
	-- 设置一个计数器，用于限制每回合特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，排除从额外卡组召唤且非灵摆怪兽的怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_PENDULUM)
end
-- 除外卡过滤函数，排除梦见之妮穆蕾莉娅，且可作为cost除外
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost(POS_FACEDOWN) and not c:IsCode(70155677)
end
-- ①效果的费用处理，检查是否为本回合第一次发动且额外卡组有3张可除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次发动①效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		-- 检查额外卡组是否有3张满足条件的卡
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_EXTRA,0,3,nil) end
	-- ①效果发动时，设置不能从额外特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果给玩家
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择3张满足条件的卡进行除外
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_EXTRA,0,3,3,nil)
	-- 将选中的卡以里侧形式除外作为费用
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 不能特殊召唤的限制条件，仅对额外卡组非灵摆怪兽生效
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_PENDULUM)
end
-- ①效果的目标处理，检查是否有足够的召唤位置和是否可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理，将卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 盖放陷阱卡所需支付的费用过滤函数，需为兽族10星且表侧表示
function s.tgfilter(c)
	return c:IsLevel(10) and c:IsRace(RACE_BEAST) and c:IsAbleToGraveAsCost() and c:IsFaceupEx()
end
-- ②效果的费用处理，检查是否有满足条件的兽族10星怪兽可送去墓地
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的兽族10星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张满足条件的卡送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 盖放陷阱卡过滤函数，需为妮穆蕾莉娅系列陷阱且可盖放
function s.setfilter(c)
	return c:IsSetCard(0x191) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的目标处理，检查是否有满足条件的陷阱卡可盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理，从卡组选择一张妮穆蕾莉娅陷阱盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择一张满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的陷阱卡盖放到场上
		Duel.SSet(tp,g)
	end
end
