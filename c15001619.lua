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
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只战士族·地属性·7星怪兽特殊召唤。
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
-- 筛选满足“对方用抽卡以外的方法从卡组把怪兽加入手卡”条件的卡：该卡当前由对方控制、之前位于卡组、加入手卡的原因不是抽卡、是怪兽且不是未确认状态。
function c15001619.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
		and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM)
end
-- ①效果的发动条件：事件组eg中存在至少1张满足cfilter过滤条件的卡，即对方确实用非抽卡方式从卡组把怪兽加入了手卡。
function c15001619.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15001619.cfilter,1,nil,tp)
end
-- ①效果的发动合法性检查：我方主要怪兽区有空位，且这张手卡能够被特殊召唤，才可发动。
function c15001619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区存在空位，用于特殊召唤这张手卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将这次特殊召唤操作登记到连锁信息中，用于连锁判定和效果响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：获取效果持有者，若此卡仍与效果关联（未被无效或离场），则将其特殊召唤。
function c15001619.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到我方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果选择怪兽的过滤条件：必须是地属性、战士族、7星怪兽，且能够被特殊召唤。
function c15001619.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性检查：我方场上有空位，且手卡·墓地中存在满足条件的怪兽。
function c15001619.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区存在空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在至少1只满足过滤条件的战士族·地属性·7星怪兽。
		and Duel.IsExistingMatchingCard(c15001619.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记从手卡·墓地特殊召唤1只怪兽的操作信息，因为不取对象，目标卡位设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 筛选我方场上的表侧表示的地属性·战士族怪兽，作为攻击力上升的适用对象。
function c15001619.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsFaceup()
end
-- ②效果处理：从手卡·墓地选择1只满足条件的怪兽特殊召唤；若特殊召唤的是「人偶国王」，则给我方场上全部战士族·地属性表侧表示怪兽赋予攻击力上升1000直到下个回合结束。
function c15001619.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认我方主要怪兽区仍有空位，否则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方手卡·墓地选择1只满足条件且不受王家长眠之谷影响的怪兽，用于特殊召唤。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15001619.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择了怪兽且特殊召唤成功，并且该怪兽的卡号是3167573（人偶国王），则继续执行攻击力提升部分。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsCode(3167573) then
		-- 获取我方场上全部表侧表示的地属性·战士族怪兽，准备为其附加攻击力提升效果。
		local g=Duel.GetMatchingGroup(c15001619.atkfilter,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- 这个效果把「人偶国王」特殊召唤的场合，自己场上的全部战士族·地属性怪兽的攻击力直到下个回合的结束时上升1000。
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
