--グリズリーファザー
local s,id,o=GetID()
-- 初始化函数，定义卡片的被战斗破坏特殊召唤怪兽和墓地除外无效怪兽效果
function s.initial_effect(c)
	-- ①效果：被战斗破坏送去墓地时才能发动。从卡组把符合条件的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②效果：把墓地的这张卡除外，使对方的怪兽效果的发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcon)
	-- 设置效果发动的代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：检查这张卡是否在墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 特殊召唤过滤条件：攻击力1400且4星的怪兽，或者当墓地有2只以上特定怪兽时的通常怪兽，且能够特殊召唤
function s.spfilter1(c,e,tp)
	return (c:IsAttack(1400) and c:IsLevel(4)
		-- 或者自己墓地存在至少2只攻击力1400的4星怪兽时，该卡是通常怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,2,nil) and c:IsType(TYPE_NORMAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地怪兽过滤条件：攻击力1400且等级4
function s.spfilter2(c,e,tp)
	return c:IsAttack(1400) and c:IsLevel(4)
end
-- 效果目标设置：检查主要怪兽区域是否有空位，以及卡组是否存在满足特召条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否还有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤过滤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：检查场上空位并让玩家从卡组选择符合条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己的主要怪兽区域没有空位则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 场上怪兽过滤条件：不是效果怪兽且为表侧表示
function s.ngfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果发动条件：对方发动怪兽效果，该发动可以被无效，且自己场上存在表侧表示的非效果怪兽
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家发动了怪兽卡的效果，且该连锁的发动能够被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 且自己场上存在至少1只表侧表示的非效果怪兽
		and Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标设置：设置无效发动以及可能破坏的操作信息
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动的卡能够被破坏，则设置破坏操作的连锁信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏该卡
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的发动无效，并检查该卡是否仍在发动效果时的位置
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelatedToChain(ev) then
		-- 将该卡破坏去墓地
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
