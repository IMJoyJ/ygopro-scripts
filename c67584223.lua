--源帝従騎テセラ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡1张「帝王」魔法·陷阱卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。进行1只怪兽的上级召唤。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只攻击力800/守备力1000的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②③效果。
function s.initial_effect(c)
	-- ①：把手卡1张「帝王」魔法·陷阱卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。进行1只怪兽的上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行上级召唤"
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只攻击力800/守备力1000的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤手卡中未公开的「帝王」魔法·陷阱卡。
function s.spcostfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsPublic()
end
-- ①号效果的Cost处理：展示手卡1张「帝王」魔法·陷阱卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外可展示的「帝王」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要确认（展示）的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡中1张满足条件的「帝王」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 给对方玩家确认选择的卡片。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手卡。
	Duel.ShuffleHand(tp)
end
-- ①号效果的发动准备（检查怪兽区域是否有空位以及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的效果处理：将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中可以进行通常召唤（或盖放）的怪兽。
function s.filter(c)
	return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
end
-- ②号效果的发动准备（检查手卡中是否存在可以进行上级召唤的怪兽）。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以进行通常召唤（或盖放）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理中的操作信息为进行1次通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②号效果的效果处理：选择手卡1只怪兽进行上级召唤（或盖放）。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家选择手卡中1张可以进行通常召唤（或盖放）的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 若该怪兽既能表侧召唤也能里侧盖放，则让玩家选择表示形式；若只能表侧召唤，则直接进行表侧召唤。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 玩家对该怪兽进行表侧表示的上级召唤（忽略每回合通常召唤次数限制）。
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 玩家对该怪兽进行里侧守备表示的上级盖放（忽略每回合通常召唤次数限制）。
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
-- 过滤卡组中攻击力800且守备力1000、并能特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttack(800) and c:IsDefense(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③号效果的发动准备（检查怪兽区域空位以及卡组中是否存在满足条件的怪兽）。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的攻击力800/守备力1000的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③号效果的效果处理：从卡组特殊召唤1只攻击力800/守备力1000的怪兽，并适用不能从额外卡组特殊召唤的限制。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择卡组中1张满足条件的攻击力800/守备力1000的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该限制效果，使其对玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的范围为额外卡组。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
