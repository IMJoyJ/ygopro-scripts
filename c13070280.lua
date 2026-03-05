--ティスティナの戯れ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把1只「提斯蒂娜」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
local s,id,o=GetID()
-- 注册主效果，设置为发动时点、可连锁、限制1回合1次
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「提斯蒂娜」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「提斯蒂娜」怪兽
function s.filter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的处理，检查是否满足发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在满足条件的「提斯蒂娜」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动处理，选择并特殊召唤符合条件的怪兽，并设置结束阶段返回手卡的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「提斯蒂娜」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 检查场上是否还有怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 设置结束阶段返回手卡的效果
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetOperation(s.thop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCountLimit(1)
			tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 结束阶段返回手卡的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽送回手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
