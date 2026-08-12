--粉砕せし破壊神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，那些发动和效果不会被无效化。
-- ①：从自己的手卡·墓地选1只「欧贝利斯克之巨神兵」特殊召唤。这个效果特殊召唤的怪兽在这个回合不受对方的效果影响。
-- ②：自己场上有「欧贝利斯克之巨神兵」存在的状态，自己为让卡的效果发动而把自己场上的怪兽2只以上同时解放的场合，把墓地的这张卡除外才能发动。对方墓地的怪兽全部除外，给与对方那个数量×500伤害。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 记录这张卡在效果中记载了「欧贝利斯克之巨神兵」的卡名
	aux.AddCodeList(c,10000000)
	-- ①：从自己的手卡·墓地选1只「欧贝利斯克之巨神兵」特殊召唤。这个效果特殊召唤的怪兽在这个回合不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「欧贝利斯克之巨神兵」存在的状态，自己为让卡的效果发动而把自己场上的怪兽2只以上同时解放的场合，把墓地的这张卡除外才能发动。对方墓地的怪兽全部除外，给与对方那个数量×500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 设置发动效果②的Cost为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤手卡·墓地中可以特殊召唤的「欧贝利斯克之巨神兵」的过滤函数
function s.spfilter(c,e,tp)
	return c:IsCode(10000000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有可以特殊召唤怪兽的空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己的手卡或墓地是否存在至少1只可以特殊召唤的「欧贝利斯克之巨神兵」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理（特殊召唤并赋予不受对方效果影响的抗性）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给发动玩家发送提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤王家长眠之谷的影响，让玩家从手卡或墓地选择1只「欧贝利斯克之巨神兵」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选出卡片，则尝试将其以表侧表示特殊召唤（分步处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不受对方的效果影响。对方墓地的怪兽全部除外，给与对方那个数量×500伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「粉碎的破坏神」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的后续处理（触发特殊召唤成功的时点）
	Duel.SpecialSummonComplete()
end
-- 免疫效果的过滤函数，判定效果来源是否为对方玩家
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 过滤被解放的、原本控制权属于自己的场上怪兽
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 过滤场上表侧表示存在的「欧贝利斯克之巨神兵」
function s.cfilter1(c)
	return c:IsCode(10000000) and c:IsFaceup()
end
-- 过滤被解放的、原本在场上表侧表示存在的「欧贝利斯克之巨神兵」
function s.cfilter2(c,tp)
	return c:IsCode(10000000) and s.cfilter(c,tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果②的发动条件判定函数
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and r&REASON_COST~=0 and eg:IsExists(s.cfilter,2,nil,tp)
		-- 检查当前场上是否存在表侧表示的「欧贝利斯克之巨神兵」
		and (Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
			or eg:IsExists(s.cfilter2,1,nil,tp))
end
-- 过滤对方墓地中可以被除外的怪兽卡
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动准备与合法性检测函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测对方墓地是否存在至少1只可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 获取对方墓地中所有可以除外的怪兽卡组
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE,nil)
	-- 设置连锁处理的操作信息为：除外对方墓地的这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	-- 设置连锁处理的操作信息为：给与对方除外数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
-- 效果②的效果处理（除外对方墓地全部怪兽并给予伤害）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地中所有可以除外的怪兽卡
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE,nil)
	-- 将这些怪兽全部表侧表示除外，并记录实际除外的数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct>0 then
		-- 给与对方实际除外数量×500的伤害
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
