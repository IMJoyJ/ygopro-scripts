--白曼波
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以同名卡在自己场上存在的自己墓地1只4星以下的鱼族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽特殊召唤。
-- ②：这张卡从墓地特殊召唤的场合才能发动。这个回合，这张卡当作调整使用。
local s,id,o=GetID()
-- 注册①②效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以同名卡在自己场上存在的自己墓地1只4星以下的鱼族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地特殊召唤的场合才能发动。这个回合，这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tncon)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
end
s.treat_itself_tuner=true
-- 过滤场上表侧表示同名卡
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤墓地4星以下且同名卡在自己场上存在的鱼族怪兽
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH)
		-- 检查场上是否存在同名卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的 Target 函数：以同名卡在自己场上存在的自己墓地1只4星以下的鱼族怪兽为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查怪兽区是否有空位以及自身是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否存在满足条件的对象怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只4星以下的鱼族怪兽为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)+c
	-- 设置操作信息：将2张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- ①效果的 Operation 函数：将这张卡特殊召唤，作为对象的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	-- 特殊召唤自身并检查怪兽区是否有空缺及青眼精灵龙限制
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and tc:IsRelateToEffect(e) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 将作为对象的怪兽特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 检查发动条件：是否从墓地特殊召唤
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ②效果的 Operation 函数：这个回合，这张卡当作调整使用
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
