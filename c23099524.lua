--ファラオニック・アドベント
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升双方的场上·墓地的永续陷阱卡数量×300。
-- ③：把自己场上1只天使族·恶魔族·爬虫类族怪兽解放才能发动。从卡组把1张永续陷阱卡加入手卡。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
function c23099524.initial_effect(c)
	-- 这个卡名的①的效果1回合各能使用1次。①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的③的效果1回合各能使用1次。③：把自己场上1只天使族·恶魔族·爬虫类族怪兽解放才能发动。从卡组把1张永续陷阱卡加入手卡。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
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
-- 定义解放代价筛选函数：检查怪兽c被解放后tp场上是否仍有可用怪兽区，以确保有位置特殊召唤这张卡。
function c23099524.rfilter(c,tp)
	-- 计算怪兽c被解放后tp场的可用怪兽区数量是否大于0，即解放后仍有空位可供特殊召唤。
	return Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的发动代价：从自己场上解放1只怪兽（需保证解放后场上仍有空位）才能发动。
function c23099524.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：检查自己场上是否存在1只可解放且解放后仍有空位的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c23099524.rfilter,1,nil,tp) end
	-- 从自己场上选择1只满足条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c23099524.rfilter,1,1,nil,tp)
	-- 将所选择的怪兽解放，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- ①效果的发动条件设定：确认这张卡可以特殊召唤，并登记特殊召唤的操作信息。
function c23099524.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁包含特殊召唤，对象为这张卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤。
function c23099524.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到其持有者/控制者tp的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力加成统计的过滤条件：表侧表示或位于墓地的永续陷阱卡。
function c23099524.atkfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)
end
-- 计算双方场上·墓地的永续陷阱卡数量并乘以300，作为这张卡的攻击力上升值。
function c23099524.atkval(e,c)
	-- 返回符合条件的永续陷阱卡数量×300。
	return Duel.GetMatchingGroupCount(c23099524.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)*300
end
-- 定义③效果可解放怪兽的条件：自己场上的天使族/恶魔族/爬虫类族怪兽（控制权为己方，表侧或里侧均可）。
function c23099524.thcfilter(c,tp)
	return c:IsRace(RACE_FAIRY+RACE_FIEND+RACE_REPTILE) and (c:IsFaceup() or c:IsControler(tp))
end
-- ③效果的发动代价：从自己场上解放1只满足条件的天使/恶魔/爬虫类族怪兽。
function c23099524.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：检查自己场上是否存在至少1只符合条件的种族怪兽可解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c23099524.thcfilter,1,nil,tp) end
	-- 从自己场上选择1只满足条件的天使/恶魔/爬虫类族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c23099524.thcfilter,1,1,nil,tp)
	-- 解放所选择的怪兽，作为发动③效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 检索过滤条件：卡组中的永续陷阱卡，且能加入手卡。
function c23099524.thfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsAbleToHand()
end
-- ③检索效果的发动条件和登记：确认卡组中有符合条件的永续陷阱卡，并设置从卡组加入手卡的操作信息。
function c23099524.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的永续陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c23099524.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为从卡组检索1张永续陷阱卡加入手卡，具体卡在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1张永续陷阱卡加入手卡，向对方确认，然后给自己附加不能特殊召唤的自肃。
function c23099524.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的永续陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c23099524.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的那张卡，进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将自肃效果注册到场上，使tp玩家直到回合结束不能特殊召唤怪兽。
	Duel.RegisterEffect(e1,tp)
end
