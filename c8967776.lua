--究極時械神セフィロン
-- 效果：
-- 这张卡不能通常召唤。自己墓地有怪兽10只以上存在的场合才能特殊召唤。1回合1次，可以把1只8星以上的天使族怪兽从自己的手卡·墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化，攻击力变成4000。
function c8967776.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不能通过自身规则以外的方式特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己墓地有怪兽10只以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c8967776.spcon)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把1只8星以上的天使族怪兽从自己的手卡·墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化，攻击力变成4000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8967776,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c8967776.sptg)
	e3:SetOperation(c8967776.spop)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件函数：检查怪兽区域空格以及墓地怪兽数量
function c8967776.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己墓地是否存在至少10只怪兽
		Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,10,nil,TYPE_MONSTER)
end
-- 过滤函数：筛选手卡·墓地中可以特殊召唤的8星以上的天使族怪兽
function c8967776.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsLevelAbove(8)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动检测与目标选择函数
function c8967776.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查自己的手卡或墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c8967776.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，用于连锁处理的检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 特殊召唤效果的具体处理函数
function c8967776.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c8967776.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功选择怪兽，则将其以表侧表示特殊召唤到场上（分步处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 攻击力变成4000。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK)
		e3:SetValue(4000)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的最终流程处理
	Duel.SpecialSummonComplete()
end
