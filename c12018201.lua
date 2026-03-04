--ラヴァルバル・エクスロード
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：手卡·场上的怪兽的效果由对方发动时才能发动。那只怪兽破坏，给与对方1000伤害。
-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从自己墓地选同调怪兽以外的最多3只守备力200的炎属性怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c12018201.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且1只以上调整以外的炎属性怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ①：手卡·场上的怪兽的效果由对方发动时才能发动。那只怪兽破坏，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,12018201)
	e1:SetCondition(c12018201.descon)
	e1:SetTarget(c12018201.destg)
	e1:SetOperation(c12018201.desop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从自己墓地选同调怪兽以外的最多3只守备力200的炎属性怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,12018202)
	e2:SetCondition(c12018201.spcon)
	e2:SetTarget(c12018201.sptg)
	e2:SetOperation(c12018201.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断函数，用于判断是否满足①效果的发动条件
function c12018201.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动时的怪兽所在位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRelateToEffect(re) and (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0
end
-- 效果的处理目标设置函数，用于设置①效果的处理目标
function c12018201.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置连锁处理中要破坏的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 设置连锁处理中要造成伤害的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理中要造成的伤害值
	Duel.SetTargetParam(1000)
	-- 设置连锁处理中要造成伤害的效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果的处理函数，用于执行①效果的处理
function c12018201.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发动的怪兽是否可以被破坏并执行破坏操作
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 获取连锁处理中设定的目标玩家和目标参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 对目标玩家造成指定伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
-- 效果发动时的条件判断函数，用于判断是否满足②效果的发动条件
function c12018201.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 特殊召唤的过滤函数，用于筛选墓地符合条件的怪兽
function c12018201.spfilter(c,e,tp)
	return not c:IsType(TYPE_SYNCHRO) and c:IsDefense(200) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的处理目标设置函数，用于设置②效果的处理目标
function c12018201.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的发动条件，检查场上是否有空位和墓地是否有符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足②效果的发动条件，检查墓地是否有符合条件的怪兽
		and Duel.IsExistingMatchingCard(c12018201.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理中要特殊召唤的卡片组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果的处理函数，用于执行②效果的处理
function c12018201.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>3 then ft=3 end
	-- 判断玩家是否受到效果影响，限制特殊召唤数量
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,c12018201.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 遍历选择的怪兽组，对每张怪兽执行特殊召唤操作
	for tc in aux.Next(g) do
		-- 执行单张怪兽的特殊召唤步骤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 为特殊召唤的怪兽添加效果，使其效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
