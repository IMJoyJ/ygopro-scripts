--グリズリーファザー
local s,id,o=GetID()
-- 初始化卡片效果：注册①战破送墓特召卡组怪兽效果、②墓地除外自身无效怪兽效果发动并破坏效果
function s.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1400的4星怪兽特殊召唤。自己墓地有2只以上攻击力1400的4星怪兽存在的场合，可以作为代替把1只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有通常怪兽存在，对方把怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcon)
	-- 设置发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：此卡因战斗破坏被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 特召卡组过滤条件：4星且攻击力1400的怪兽，或墓地满足条件时可为通常怪兽
function s.spfilter1(c,e,tp)
	return (c:IsAttack(1400) and c:IsLevel(4)
		-- 检查墓地是否有至少2只攻击力1400的4星怪兽，使可特召范围扩大至任意通常怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,2,nil) and c:IsType(TYPE_NORMAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地条件检查过滤条件：攻击力1400的4星怪兽
function s.spfilter2(c,e,tp)
	return c:IsAttack(1400) and c:IsLevel(4)
end
-- ①效果发动准备：检查格子与卡组可特召怪兽，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组中是否存在满足特召条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只满足条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 通常怪兽存在检查过滤条件：非效果怪兽且表侧表示
function s.ngfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- ②效果发动条件：场上有非效果怪兽且对方发动怪兽效果（可被无效）
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果且该连锁发动可被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的非效果怪兽
		and Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动准备：设置无效发动与破坏卡片的操作信息
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：无效连锁发动的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息：破坏发动的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方发动的怪兽效果并将其破坏
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效连锁发动的效果，并确认发动卡片是否关联连锁
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelatedToChain(ev) then
		-- 将该发动的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
