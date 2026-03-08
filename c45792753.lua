--ゴーティス・チェイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的鱼族怪兽除外才能发动。原本卡名和为这张卡发动而除外的怪兽不同的1只「魊影」怪兽从自己的手卡·卡组·墓地·除外状态特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡的效果，设置为发动时点、自由连锁、特殊召唤类别、发动次数限制为1次
function s.initial_effect(c)
	-- ①：把自己场上1只表侧表示的鱼族怪兽除外才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在满足条件的鱼族怪兽（表侧表示、可除外、有空怪兽区、且存在符合条件的特殊召唤怪兽）
function s.cfilter(c,e,tp)
	-- 检查场上是否存在满足条件的鱼族怪兽（表侧表示、可除外、有空怪兽区）
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 检查是否存在满足条件的「魊影」怪兽（可特殊召唤、卡名与除外怪兽不同）
		and Duel.IsExistingMatchingCard(s.filter,tp,0x33,0,1,nil,e,tp,c:GetOriginalCode())
end
-- 过滤函数，检查目标怪兽是否为「魊影」族、可特殊召唤、且卡号与指定卡号不同
function s.filter(c,e,tp,code)
	return c:IsFaceupEx() and c:IsSetCard(0x18a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(code)
end
-- 处理效果的发动阶段，选择并除外一只鱼族怪兽，设置发动时的特殊召唤目标
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件（已支付代价、场上存在符合条件的鱼族怪兽）
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一只满足条件的鱼族怪兽
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽除外作为发动代价
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetLabel(tc:GetOriginalCode())
	-- 设置效果处理时要特殊召唤的怪兽信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x33)
end
-- 处理效果的发动效果，选择并特殊召唤符合条件的「魊影」怪兽，若成功则设置其离场时除外的效果
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的怪兽区进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只满足条件的「魊影」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,0x33,0,1,1,nil,e,tp,e:GetLabel())
	-- 将选中的怪兽特殊召唤到场上
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
