--グリズリーファザー
local s,id,o=GetID()
-- 初始化卡片效果：注册①战破送墓从卡组特召4星攻1400怪兽（或通常怪兽）效果、②场上有非效果怪兽时墓地除外无效并破坏对方怪兽效果发动的效果
function s.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合才能发动。从卡组把1只攻击力1400的4星怪兽特殊召唤。自己墓地有2只以上攻击力1400的4星怪兽存在的场合，也可以作为代替把1只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在，对方把怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcon)
	-- ②效果发动Cost：把墓地的此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：此卡在墓地存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 卡组特召过滤条件：攻击力1400的4星怪兽，或墓地有2只以上攻1400的4星怪兽时的通常怪兽
function s.spfilter1(c,e,tp)
	return (c:IsAttack(1400) and c:IsLevel(4)
		-- 代替特召分支条件：自己墓地存在至少2只攻击力1400的4星怪兽时，可选择通常怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,2,nil) and c:IsType(TYPE_NORMAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地数量计数过滤：攻击力1400的4星怪兽
function s.spfilter2(c,e,tp)
	return c:IsAttack(1400) and c:IsLevel(4)
end
-- ①效果发动准备：检查怪兽区域格数与卡组是否存在可特召怪兽，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组中存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1只符合条件的怪兽表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 场上怪兽过滤：表侧表示的效果怪兽以外的怪兽
function s.ngfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- ②效果发动条件：对方发动怪兽效果，且自己场上存在表侧表示的非效果怪兽
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的可无效的怪兽效果
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的非效果怪兽
		and Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动准备：设置无效发动与破坏卡片的操作信息
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：无效效果的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息：破坏发动效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方怪兽效果的发动并将其破坏
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效效果的发动，并检查该卡是否仍关联连锁
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelatedToChain(ev) then
		-- 破坏效果被无效的怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
