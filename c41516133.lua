--超巨大戦艦 メタル・スレイブ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡·卡组把最多5只10星以下的「巨大战舰」怪兽送去墓地才能发动（同名卡最多1张）。这张卡从手卡特殊召唤。那之后，为这个效果发动而送去墓地的数量的指示物给这张卡放置。
-- ②：自己·对方回合，把这张卡1个指示物取除，以包含自己场上的「巨大战舰」怪兽的场上2张表侧表示卡为对象才能发动（同一连锁上最多1次）。那些卡破坏。
local s,id,o=GetID()
-- 注册卡片的两个效果，①为起动效果，从手卡特殊召唤；②为诱发即时效果，消耗指示物破坏对方场上卡牌
function s.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- ①：从手卡·卡组把最多5只10星以下的「巨大战舰」怪兽送去墓地才能发动（同名卡最多1张）。这张卡从手卡特殊召唤。那之后，为这个效果发动而送去墓地的数量的指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡1个指示物取除，以包含自己场上的「巨大战舰」怪兽的场上2张表侧表示卡为对象才能发动（同一连锁上最多1次）。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义用于筛选满足条件的「巨大战舰」怪兽的过滤函数，要求为10星以下且可作为墓地代价
function s.costfilter(c)
	return c:IsSetCard(0x15) and c:IsLevelBelow(10) and c:IsAbleToGraveAsCost()
end
-- 处理①效果的费用支付阶段，从手卡和卡组中选择1~5张符合条件的卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡和卡组中所有符合条件的卡牌组
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	-- 检查是否存在至少1张符合条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡牌中选择1~5张，确保卡名不重复
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,5)
	-- 将选中的卡牌送去墓地作为费用
	Duel.SendtoGrave(tg,REASON_COST)
	e:SetLabel(tg:GetCount())
end
-- 设置①效果的发动条件，检查是否满足特殊召唤的条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果的处理，将此卡特殊召唤并放置指示物
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在连锁中且特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and e:GetLabel()>0 and c:IsCanAddCounter(0x1f,e:GetLabel()) then
		-- 中断当前效果处理，使后续处理不同时进行
		Duel.BreakEffect()
		c:AddCounter(0x1f,e:GetLabel())
	end
end
-- 处理②效果的费用支付阶段，移除1个指示物作为代价
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1f,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_COST)
end
-- 定义用于筛选场上表侧表示卡的过滤函数，要求为表侧表示且可成为效果对象
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 定义用于筛选自己场上的「巨大战舰」怪兽的过滤函数
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x15) and c:IsControler(tp)
end
-- 定义用于检查卡组是否满足破坏条件的函数，要求至少存在1张自己场上的「巨大战舰」怪兽
function s.fselect(g,tp)
	return g:IsExists(s.desfilter,1,nil,tp)
end
-- 设置②效果的目标选择阶段，从场上选择2张符合条件的卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有符合条件的卡牌组
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return rg:CheckSubGroup(s.fselect,2,2,tp) end
	-- 提示玩家选择要破坏的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,2,tp)
	-- 设置当前效果的目标卡牌
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息，表示将破坏这些卡牌
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- 执行②效果的处理，破坏目标卡牌
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前连锁中与效果相关的卡牌破坏
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
