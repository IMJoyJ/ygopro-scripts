--ファイアウォール・ディフェンサー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。从卡组把「防火防守者」以外的1只「防火」怪兽特殊召唤。
-- ②：自己场上的「防火」怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c20455229.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。从卡组把「防火防守者」以外的1只「防火」怪兽特殊召唤。
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
	-- 注册自定义活动计数器，用于检测玩家在当前回合是否特殊召唤过非电子界族怪兽
	Duel.AddCustomActivityCounter(20455229,ACTIVITY_SPSUMMON,c20455229.counterfilter)
end
-- 过滤表侧表示的电子界族怪兽
function c20455229.counterfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsFaceup()
end
-- 确认这张卡是否作为电子界族连接怪兽的连接素材送去墓地
function c20455229.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and rc:IsRace(RACE_CYBERSE)
end
-- 效果①的发动代价与限制：确认本回合是否特殊召唤过非电子界族怪兽，并施加不能特殊召唤非电子界族怪兽的誓约限制
function c20455229.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家在当前回合是否未曾特殊召唤过非电子界族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(20455229,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c20455229.splimit)
	-- 将本回合不能特殊召唤非电子界族怪兽的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽不能是电子界族以外的怪兽
function c20455229.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 过滤卡组中「防火防守者」以外且可以特殊召唤的「防火」怪兽
function c20455229.spfilter(c,e,tp)
	return not c:IsCode(20455229) and c:IsSetCard(0x18f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检测：确认主要怪兽区域有空位，且卡组存在符合条件的特殊召唤怪兽
function c20455229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上的主要怪兽区域是否有可供特殊召唤的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在至少1只符合条件的「防火」怪兽
		and Duel.IsExistingMatchingCard(c20455229.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组中选择1只符合条件的「防火」怪兽特殊召唤
function c20455229.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区域已无可用空格，则直接返回不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的「防火」怪兽
	local g=Duel.SelectMatchingCard(tp,c20455229.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的「防火」怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上被效果破坏的表侧表示的「防火」怪兽
function c20455229.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup() and c:IsSetCard(0x18f) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 效果②的代替破坏条件检测：确认墓地的这张卡能除外，且场上有自己要被效果破坏的表侧表示的「防火」怪兽
function c20455229.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c20455229.repfilter,1,nil,tp) end
	-- 询问玩家是否使用墓地的这张卡代替破坏
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的价值判定过滤：确认代替破坏的对象是自己场上的表侧表示「防火」怪兽
function c20455229.repval(e,c)
	return c20455229.repfilter(c,e:GetHandlerPlayer())
end
-- 效果②的代替破坏效果处理：把墓地的这张卡除外代替破坏
function c20455229.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 作为代替，将墓地的这张卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
