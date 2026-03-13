--幻惑のバリア －ミラージュフォース－
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤，那只攻击怪兽回到手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的幻想魔族怪兽因对方的效果从场上离开的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤，那只攻击怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的幻想魔族怪兽因对方的效果从场上离开的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方怪兽攻击宣言
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- 过滤满足条件的幻想魔族怪兽
function s.filter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的条件检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() and at:IsAbleToHand()
		-- 检查场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在符合条件的幻想魔族怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置将攻击怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,at,1,0,0)
	-- 设置特殊召唤幻想魔族怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果①的主要操作流程
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的幻想魔族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 执行特殊召唤并判断是否成功
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取攻击怪兽
		local at=Duel.GetAttacker()
		if at:IsRelateToBattle() then
			-- 将攻击怪兽送回手牌
			Duel.SendtoHand(at,nil,REASON_EFFECT)
		end
	end
end
-- 过滤因对方效果离开场上的幻想魔族怪兽
function s.spcfilter(c,tp)
	return bit.band(c:GetPreviousRaceOnField(),RACE_ILLUSION)~=0 and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断是否有符合条件的幻想魔族怪兽因对方效果离场
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
-- 设置效果②处理时的条件检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local at=Duel.GetAttacker()
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在符合条件的幻想魔族怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤幻想魔族怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果②的主要操作流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的幻想魔族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
