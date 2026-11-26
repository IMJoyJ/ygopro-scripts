--グリズリーファザー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1400的4星怪兽特殊召唤。自己墓地有攻击力1400的4星怪兽2只以上存在的场合，也能作为代替把1只通常怪兽特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在，对方把怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①被战破送墓时从卡组特召攻1400的4星怪兽（或通常怪兽）的效果，以及②己方场上有非效果怪兽时墓地除外自身康对方怪兽效果的二速效果
function s.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1400的4星怪兽特殊召唤。自己墓地有攻击力1400的4星怪兽2只以上存在的场合，也能作为代替把1只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有效果怪兽以外的表侧表示怪兽存在，对方把怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcon)
	-- 设置②效果的发动代价为将墓地的此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
end
-- 检查①效果发动条件：被战斗破坏后当前位于墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤卡组中攻击力1400且4星的怪兽，或在墓地有2只以上攻1400的4星怪兽时也允许过滤通常怪兽（且均需可特殊召唤）
function s.spfilter1(c,e,tp)
	return (c:IsAttack(1400) and c:IsLevel(4)
		-- 或者己方墓地存在至少2只攻击力1400的4星怪兽时，允许选择通常怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,2,nil) and c:IsType(TYPE_NORMAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤攻击力1400且等级4的怪兽
function s.spfilter2(c,e,tp)
	return c:IsAttack(1400) and c:IsLevel(4)
end
-- 发动前确认己方怪兽区有空位且卡组存在符合条件的可特召怪兽，并登记特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区是否至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组是否存在至少1只满足spfilter1条件的可特殊召唤怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记从己方卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：检查空位后从己方卡组选择1只满足spfilter1条件的怪兽表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查己方怪兽区是否仍有空位，无空位则中止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向己方发送从卡组选择要特殊召唤的怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从卡组选择1只攻击力1400的4星怪兽（条件满足时亦可选通常怪兽）
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤表侧表示且非效果怪兽的怪兽
function s.ngfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 检查②效果发动条件：对方发动了可被无效的怪兽效果，且己方怪兽区存在非效果怪兽的表侧怪兽
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动连锁的玩家为对方、触发的是怪兽效果且该连锁的发动可被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 并检查己方怪兽区是否存在至少1只效果怪兽以外的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动前登记无效发动的操作信息，若效果来源卡可破坏且与效果关联则同时登记破坏操作信息
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记无效该连锁发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记将发动效果的卡片破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方怪兽效果的发动，若该卡仍在当前连锁中则将其以效果破坏
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽效果的发动无效，并确认该怪兽卡仍与该连锁关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将发动效果被无效的怪兽以效果破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
