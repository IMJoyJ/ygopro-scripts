--クロノダイバー・レギュレーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有这张卡以外的怪兽存在的场合，把这张卡解放才能发动。从卡组把「时间潜行者规范针表犬」以外的2只「时间潜行者」怪兽守备表示特殊召唤（同名卡最多1张）。
-- ②：这张卡在墓地存在的状态，自己的超量怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19891131.initial_effect(c)
	-- 创建①效果，为起动效果，只能在主要怪兽区使用，限制1回合1次，发动条件为己方场上只有这张卡，支付代价为解放自己，效果为特殊召唤2只「时间潜行者」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19891131,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19891131)
	e1:SetCondition(c19891131.spcon)
	e1:SetCost(c19891131.spcost)
	e1:SetTarget(c19891131.sptg)
	e1:SetOperation(c19891131.spop)
	c:RegisterEffect(e1)
	-- 创建②效果，为诱发即时效果，只能在墓地使用，限制1回合1次，发动条件为己方超量怪兽被战斗破坏，效果为特殊召唤自己，且特殊召唤的自己离开场上的时候不会送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(19891131,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19891132)
	e2:SetCondition(c19891131.spcon2)
	e2:SetTarget(c19891131.sptg2)
	e2:SetOperation(c19891131.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己场上没有这张卡以外的怪兽存在
function c19891131.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有这张卡以外的怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 效果①的发动代价：解放自己
function c19891131.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自己作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST+REASON_RELEASE)
end
-- 筛选满足条件的「时间潜行者」怪兽，排除自己，可以特殊召唤
function c19891131.spfilter(c,e,tp)
	return c:IsSetCard(0x126) and not c:IsCode(19891131) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动时点处理，检查是否有满足条件的怪兽可以特殊召唤，且己方没有被【青眼精灵龙】影响
function c19891131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足特殊召唤条件的「时间潜行者」怪兽组
		local g=Duel.GetMatchingGroup(c19891131.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果①的发动处理，检查是否被【青眼精灵龙】影响，是否有足够的怪兽区，选择并特殊召唤2只满足条件的怪兽
function c19891131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 己方怪兽区不足2个
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取满足特殊召唤条件的「时间潜行者」怪兽组
	local g=Duel.GetMatchingGroup(c19891131.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的怪兽组中选择2只不同卡名的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选择的2只怪兽特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 筛选被战斗破坏的超量怪兽，判断其是否为己方控制
function c19891131.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsPreviousControler(tp)
end
-- 效果②的发动条件：己方超量怪兽被战斗破坏
function c19891131.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19891131.cfilter,1,nil,tp)
end
-- 效果②的发动时点处理，检查是否可以特殊召唤自己
function c19891131.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 己方怪兽区不足1个
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的发动处理，检查是否可以特殊召唤自己，若可以则特殊召唤并设置效果使其离开场上时除外
function c19891131.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己是否还在场上，若在则特殊召唤自己
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置效果，使特殊召唤的自己离开场上时除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
