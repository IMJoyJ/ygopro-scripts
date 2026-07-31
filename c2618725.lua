--GMX同絆者セランディア
-- 效果：
-- 可以把手卡的这张卡给对方出示；从手卡把1只「GMX」怪兽或者恐龙族怪兽特殊召唤，这个回合，自己不用「GMX」怪兽不能直接攻击。
-- 这张卡用怪兽的效果特殊召唤的场合：可以把自己手卡·墓地·除外状态的4星以下的1只「GMX」怪兽或者恐龙族怪兽以守备表示特殊召唤。
-- 「GMX合作伙伴 塞兰特亚」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片的两个效果，第一个为手卡特殊召唤效果，第二个为用怪兽效果特殊召唤时的效果
function s.initial_effect(c)
	-- 从手卡特殊召唤1只「GMX」怪兽或者恐龙族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	-- 从手卡·墓地·除外状态特殊召唤4星以下的1只「GMX」怪兽或者恐龙族怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·墓地·除外状态特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用处理，确认自己手牌并洗切手牌
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	-- 向对方玩家展示自己的手牌
	Duel.ConfirmCards(1-tp,c)
	-- 将自己手牌洗切
	Duel.ShuffleHand(tp)
end
-- 定义用于筛选手卡中可特殊召唤的「GMX」或恐龙族怪兽的过滤函数
function s.spfilter1(c,e,tp)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置第一个效果的目标，检查是否有满足条件的怪兽可以特殊召唤
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行第一个效果的操作，设置不能直接攻击的效果并选择特殊召唤怪兽
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 注册不能直接攻击的效果，选择并特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.dirlim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能直接攻击的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 检查场上是否有空位，没有则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义不能直接攻击效果的目标限制函数，只有非「GMX」怪兽不能直接攻击
function s.dirlim(e,c)
	return not c:IsSetCard(0x1dd)
end
-- 判断是否由怪兽的效果特殊召唤成功
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 定义用于筛选手卡·墓地·除外状态中可特殊召唤的4星以下「GMX」或恐龙族怪兽的过滤函数
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsFaceupEx()
end
-- 设置第二个效果的目标，检查是否有满足条件的怪兽可以特殊召唤
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地·除外状态中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要从手卡·墓地·除外状态特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 执行第二个效果的操作，选择并特殊召唤怪兽
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，没有则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地·除外状态中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
