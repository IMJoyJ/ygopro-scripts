--B・F－決戦のビッグ・バリスタ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡特殊召唤成功的场合，把自己墓地的昆虫族怪兽全部除外才能发动。对方场上的全部怪兽的攻击力·守备力下降除外中的自己的昆虫族怪兽数量×500。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：同调召唤的这张卡被对方破坏的场合才能发动。选除外的3只自己的11星以下的昆虫族怪兽特殊召唤。
function c26443791.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整，1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，把自己墓地的昆虫族怪兽全部除外才能发动。对方场上的全部怪兽的攻击力·守备力下降除外中的自己的昆虫族怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(c26443791.atkcost)
	e1:SetTarget(c26443791.atktg)
	e1:SetOperation(c26443791.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡被对方破坏的场合才能发动。选除外的3只自己的11星以下的昆虫族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c26443791.spcon)
	e3:SetTarget(c26443791.sptg)
	e3:SetOperation(c26443791.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的昆虫族怪兽，用于除外作为代价
function c26443791.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 检索满足条件的昆虫族怪兽并除外作为代价
function c26443791.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c26443791.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 将满足条件的昆虫族怪兽除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果目标，检查对方场上是否存在表侧表示怪兽
function c26443791.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 过滤满足条件的昆虫族表侧表示怪兽，用于计算攻击力和守备力下降值
function c26443791.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 为对方场上所有表侧表示怪兽增加攻击力和守备力下降效果
function c26443791.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	-- 计算除外的昆虫族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c26443791.atkfilter,tp,LOCATION_REMOVED,0,nil)
	while tc do
		-- 为对方场上所有表侧表示怪兽增加攻击力下降效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*-500)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 判断是否满足效果发动条件，即被对方破坏且为同调召唤
function c26443791.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的昆虫族11星以下的怪兽，用于特殊召唤
function c26443791.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，检查是否满足发动条件
function c26443791.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查是否满足除外的昆虫族怪兽数量条件
		and Duel.IsExistingMatchingCard(c26443791.spfilter,tp,LOCATION_REMOVED,0,3,nil,e,tp) end
	-- 设置操作信息，确定特殊召唤的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_REMOVED)
end
-- 执行特殊召唤操作，从除外区选择3只符合条件的昆虫族怪兽特殊召唤
function c26443791.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的3只昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c26443791.spfilter,tp,LOCATION_REMOVED,0,3,3,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
