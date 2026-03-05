--ファイアウォール・ディフェンサー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。从卡组把「防火防守者」以外的1只「防火」怪兽特殊召唤。
-- ②：自己场上的「防火」怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c20455229.initial_effect(c)
	-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。从卡组把「防火防守者」以外的1只「防火」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,20455229)
	e1:SetCondition(c20455229.spcon)
	e1:SetCost(c20455229.spcost)
	e1:SetTarget(c20455229.sptg)
	e1:SetOperation(c20455229.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「防火」怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20455230)
	e2:SetTarget(c20455229.reptg)
	e2:SetValue(c20455229.repval)
	e2:SetOperation(c20455229.repop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在回合中特殊召唤的电子界族怪兽数量
	Duel.AddCustomActivityCounter(20455229,ACTIVITY_SPSUMMON,c20455229.counterfilter)
end
-- 计数器的过滤函数，判断卡片是否为电子界族
function c20455229.counterfilter(c)
	return c:IsRace(RACE_CYBERSE)
end
-- 效果发动的条件：这张卡作为电子界族连接怪兽的连接素材被送去墓地
function c20455229.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and rc:IsRace(RACE_CYBERSE)
end
-- 效果的费用：检查本回合是否已经发动过此效果，若未发动则设置不能特殊召唤非电子界族怪兽的效果
function c20455229.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已经发动过此效果，若未发动则可以发动
	if chk==0 then return Duel.GetCustomActivityCount(20455229,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响全场的永续效果，使本回合不能特殊召唤非电子界族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c20455229.splimit)
	-- 将费用效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非电子界族怪兽的效果函数
function c20455229.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 筛选满足条件的「防火」怪兽的过滤函数
function c20455229.spfilter(c,e,tp)
	return not c:IsCode(20455229) and c:IsSetCard(0x18f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件：确认场上是否有足够的空间并检查卡组中是否存在符合条件的怪兽
function c20455229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「防火」怪兽
		and Duel.IsExistingMatchingCard(c20455229.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，表示将特殊召唤1只「防火」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数：选择并特殊召唤符合条件的怪兽
function c20455229.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c20455229.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于判断是否可以作为代替破坏的「防火」怪兽的过滤函数
function c20455229.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup() and c:IsSetCard(0x18f) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 代替破坏效果的发动条件：确认墓地中的这张卡可以除外，并且有符合条件的怪兽被破坏
function c20455229.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c20455229.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的值函数，返回是否可以代替破坏的怪兽
function c20455229.repval(e,c)
	return c20455229.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数：将这张卡从墓地除外
function c20455229.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
