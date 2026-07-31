--グリズリーファザー
local s,id,o=GetID()
-- 定义卡片初始效果函数，用于注册卡牌的效果。
function s.initial_effect(c)
	-- 创建并注册一个特殊召唤怪兽的效果。此效果在战斗破坏时触发。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建并注册一个使发动无效和破坏怪兽的效果。此效果在连锁发动时触发。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcon)
	-- 设置该效果的cost为将这张卡从场上除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤效果的条件，判断自身是否在墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 定义特殊召唤效果的过滤函数，用于选择满足条件的怪兽。如果攻击力1400且等级为4，或者对方墓地有2张或更多攻击力1400且等级为4的通常怪兽，则可以被选中。
function s.spfilter1(c,e,tp)
	return (c:IsAttack(1400) and c:IsLevel(4)
		-- 判断对方墓地是否存在符合条件的怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,2,nil) and c:IsType(TYPE_NORMAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤效果的辅助过滤函数，用于检查攻击力和等级是否满足条件。
function s.spfilter2(c,e,tp)
	return c:IsAttack(1400) and c:IsLevel(4)
end
-- 定义特殊召唤效果的目标选择函数，判断玩家场上是否有怪兽区以及卡组中是否有满足条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家的怪兽区域是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合特殊召唤条件（s.spfilter1）的卡片
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前处理的操作信息为特殊召唤，目标数量为1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义特殊召唤效果的处理函数，如果怪兽区已满则结束。提示玩家选择要特殊召唤的卡牌，并进行特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区域没有空位则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择满足过滤条件（s.spfilter1）的1张卡牌。
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡牌以正面表示进行特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义使发动无效和破坏怪兽效果的过滤函数，判断目标是否不是效果怪兽且是表侧表示。
function s.ngfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 定义使发动无效和破坏怪兽效果的条件，判断对方玩家回合、目标为怪兽类型、连锁可以被无效化以及场上是否存在满足ngfilter条件的卡牌。
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合，且连锁中的卡片是怪兽，并且该连锁可以被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 判断场上是否存在表侧表示的非效果怪兽
		and Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义使发动无效和破坏怪兽效果的目标选择函数，如果目标可破坏且与效果有关联则设置破坏操作。
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的操作信息为使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果目标卡片可以被破坏并且与该效果相关联，则设置当前处理的操作信息为破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义使发动无效和破坏怪兽效果的处理函数，如果成功使连锁无效且目标与连锁有关联，则进行破坏。
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使连锁无效，并且连锁中的卡片与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelatedToChain(ev) then
		-- 以效果为理由破坏目标卡牌。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
