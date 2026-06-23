--地縛戒隷 ジオグリフォン
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合可以发动。从自己墓地把「地缚戒隶 地画狮鹫」以外的1只「地缚」怪兽守备表示特殊召唤。这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被对方破坏的场合才能发动。场上1张卡破坏。那之后，给与对方为自己的场上·墓地的「地缚」怪兽种类×300伤害。
local s,id,o=GetID()
-- 初始化卡片效果，设置同调召唤条件并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只暗属性调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	-- ①：自己·对方回合可以发动。从自己墓地把「地缚戒隶 地画狮鹫」以外的1只「地缚」怪兽守备表示特殊召唤。这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合才能发动。场上1张卡破坏。那之后，给与对方为自己的场上·墓地的「地缚」怪兽种类×300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「地缚」怪兽，用于特殊召唤
function s.filter(c,e,tp)
	return c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(id)
end
-- 判断是否可以发动效果，检查是否有满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，确定特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理特殊召唤效果，选择并特殊召唤怪兽，并设置不能特殊召唤非融合/同调怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 创建并注册不能特殊召唤非融合/同调怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤的怪兽类型
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 判断是否为对方破坏的场合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp
end
-- 过滤场上或墓地的「地缚」怪兽
function s.dfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER)
end
-- 判断是否可以发动效果，检查场上是否有卡以及是否有满足条件的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #g>0
		-- 检查墓地或场上是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	-- 计算场上和墓地的「地缚」怪兽种类数
	local ct=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	-- 设置操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，确定要给予的伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 处理效果的破坏和伤害部分，选择并破坏卡，然后计算并造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的一张卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	-- 显示选中的卡作为破坏对象
	Duel.HintSelection(g)
	-- 破坏选中的卡
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 再次计算场上和墓地的「地缚」怪兽种类数
		local ct=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
		if ct>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 给与对方相应数量的伤害
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end
