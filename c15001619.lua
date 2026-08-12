--パペット・クィーン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方用抽卡以外的方法从卡组把怪兽加入手卡时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只战士族·地属性·7星怪兽特殊召唤。这个效果把「人偶国王」特殊召唤的场合，自己场上的全部战士族·地属性怪兽的攻击力直到下个回合的结束时上升1000。
function c15001619.initial_effect(c)
	-- ①：对方用抽卡以外的方法从卡组把怪兽加入手卡时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15001619,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c15001619.spcon)
	e1:SetTarget(c15001619.sptg)
	e1:SetOperation(c15001619.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只战士族·地属性·7星怪兽特殊召唤。这个效果把「人偶国王」特殊召唤的场合，自己场上的全部战士族·地属性怪兽的攻击力直到下个回合的结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15001619,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,15001619)
	e2:SetTarget(c15001619.sptg2)
	e2:SetOperation(c15001619.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：对方从卡组用非抽卡方式将怪兽加入手牌的卡
function c15001619.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
		and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM)
end
-- 条件判断：对方用抽卡以外的方法从卡组把怪兽加入手卡
function c15001619.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15001619.cfilter,1,nil,tp)
end
-- 效果处理准备：判断是否满足特殊召唤条件
function c15001619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自己特殊召唤
function c15001619.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：战士族·地属性·7星怪兽
function c15001619.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理准备：判断是否满足特殊召唤条件
function c15001619.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c15001619.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只战士族·地属性·7星怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：场上正面表示的战士族·地属性怪兽
function c15001619.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsFaceup()
end
-- 效果处理：选择并特殊召唤1只战士族·地属性·7星怪兽，若为「人偶国王」则提升场上所有战士族·地属性怪兽攻击力
function c15001619.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只战士族·地属性·7星怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15001619.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 判断是否成功特殊召唤且为「人偶国王」
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsCode(3167573) then
		-- 获取场上所有正面表示的战士族·地属性怪兽
		local g=Duel.GetMatchingGroup(c15001619.atkfilter,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- 给场上所有战士族·地属性怪兽的攻击力加上1000
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
