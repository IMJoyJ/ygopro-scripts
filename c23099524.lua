--ファラオニック・アドベント
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升双方的场上·墓地的永续陷阱卡数量×300。
-- ③：把自己场上1只天使族·恶魔族·爬虫类族怪兽解放才能发动。从卡组把1张永续陷阱卡加入手卡。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
function c23099524.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23099524,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,23099524)
	e1:SetCost(c23099524.spcost)
	e1:SetTarget(c23099524.sptg)
	e1:SetOperation(c23099524.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升双方的场上·墓地的永续陷阱卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c23099524.atkval)
	c:RegisterEffect(e2)
	-- ③：把自己场上1只天使族·恶魔族·爬虫类族怪兽解放才能发动。从卡组把1张永续陷阱卡加入手卡。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23099524,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,23099525)
	e3:SetCost(c23099524.thcost)
	e3:SetTarget(c23099524.thtg)
	e3:SetOperation(c23099524.thop)
	c:RegisterEffect(e3)
end
-- 检查玩家场上是否存在至少1张满足条件的可解放的卡（非上级召唤用）
function c23099524.rfilter(c,tp)
	-- 返回玩家场上可用的怪兽区数量
	return Duel.GetMZoneCount(tp,c)>0
end
-- 检查玩家场上是否存在至少1张满足条件的可解放的卡（非上级召唤用），若存在则选择1张进行解放
function c23099524.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的卡（非上级召唤用）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c23099524.rfilter,1,nil,tp) end
	-- 选择满足条件的1张可解放的卡
	local g=Duel.SelectReleaseGroup(tp,c23099524.rfilter,1,1,nil,tp)
	-- 以REASON_COST原因解放目标卡
	Duel.Release(g,REASON_COST)
end
-- 判断此卡是否可以特殊召唤
function c23099524.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 将此卡特殊召唤到场上
function c23099524.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以特殊召唤方式加入场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的永续陷阱卡
function c23099524.atkfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)
end
-- 计算双方场上和墓地的永续陷阱卡数量并乘以300作为攻击力
function c23099524.atkval(e,c)
	-- 返回双方场上和墓地的永续陷阱卡数量乘以300
	return Duel.GetMatchingGroupCount(c23099524.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)*300
end
-- 过滤满足条件的天使族·恶魔族·爬虫类族怪兽
function c23099524.thcfilter(c,tp)
	return c:IsRace(RACE_FAIRY+RACE_FIEND+RACE_REPTILE) and (c:IsFaceup() or c:IsControler(tp))
end
-- 检查玩家场上是否存在至少1张满足条件的可解放的卡（非上级召唤用），若存在则选择1张进行解放
function c23099524.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的卡（非上级召唤用）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c23099524.thcfilter,1,nil,tp) end
	-- 选择满足条件的1张可解放的卡
	local g=Duel.SelectReleaseGroup(tp,c23099524.thcfilter,1,1,nil,tp)
	-- 以REASON_COST原因解放目标卡
	Duel.Release(g,REASON_COST)
end
-- 过滤满足条件的永续陷阱卡
function c23099524.thfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsAbleToHand()
end
-- 判断卡组中是否存在满足条件的永续陷阱卡
function c23099524.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23099524.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组检索1张永续陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组选择1张永续陷阱卡加入手牌，并设置效果限制
function c23099524.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,c23099524.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将目标卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 直到回合结束时自己不能把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册效果，使玩家在本回合不能特殊召唤怪兽
	Duel.RegisterEffect(e1,tp)
end
