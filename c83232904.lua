--道化の一座『極芸』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组·额外卡组把最多2只「道化一座」怪兽无视召唤条件特殊召唤。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，把自己的手卡·场上1只怪兽解放，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的入口函数。
function s.initial_effect(c)
	-- ①：从卡组·额外卡组把最多2只「道化一座」怪兽无视召唤条件特殊召唤。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，把自己的手卡·场上1只怪兽解放，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组·额外卡组中满足特殊召唤条件的「道化一座」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 若卡片在卡组，检查自己场上是否有可用的怪兽区域。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，检查自己场上是否有可用于特殊召唤额外卡组怪兽的区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果①的发动准备与合法性检查。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的「道化一座」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组·额外卡组特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ft1
		and g:FilterCount(s.exfilter2,nil)<=ft2
		and g:FilterCount(s.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 效果①的处理：特殊召唤怪兽并施加后续的发动限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if ft1>0 then loc=loc+LOCATION_DECK end
	if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,loc,0,nil,e,tp)
	if sg:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rg=sg:SelectSubGroup(tp,s.gcheck,false,1,2,ft1,ft2,ft3,ect,ft)
	Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，把自己的手卡·场上1只怪兽解放，以场上1张卡为对象才能发动。那张卡回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 给玩家注册该效果发动限制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能发动从卡组·额外卡组特殊召唤的怪兽的效果。
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤场上可以回到手牌的卡（排除解放的怪兽及其装备卡）。
function s.thfilter(c,rc)
	return c:GetEquipTarget()~=rc and c~=rc and c:IsAbleToHand()
end
-- 过滤可解放的怪兽，且该怪兽解放后场上仍存在可回到手牌的卡。
function s.cfilter(c,tp)
	-- 检查场上是否存在至少1张可以作为回到手牌对象的卡（排除自身及自身装备的卡）。
	return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c)
end
-- 效果②的发动代价处理（除外自身并解放1只怪兽）。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能将墓地的这张卡除外，并解放手卡·场上的一只怪兽。
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,nil,tp) end
	-- 将墓地的这张卡除外。
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 选择手卡·场上1只满足条件的怪兽解放。
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,nil,tp)
	-- 解放选择的怪兽。
	Duel.Release(g,REASON_COST)
end
-- 效果②的对象选择与合法性检查。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在可以回到手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要回到手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡作为回到手牌的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置回到手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：使目标卡片回到手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将该卡送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
