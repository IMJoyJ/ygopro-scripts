--閃刀姫＝ゼロ
-- 效果：
-- 「闪刀姬」怪兽2只
-- 自己对「闪刀姬=零露」1回合只能有1次特殊召唤，这张卡不能作为连接素材。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「闪刀」魔法卡加入手卡。
-- ②：自己·对方回合，把这张卡解放才能发动。「闪刀姬-零衣」「闪刀姬-露世」各1只从自己的卡组·墓地特殊召唤。那之后，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 初始化效果注册
function s.initial_effect(c)
	-- 将「闪刀姬-零衣」与「闪刀姬-露世」加入该卡的关联卡片列表
	aux.AddCodeList(c,26077387,37351133)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：使用2只「闪刀姬」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x1115),2,2)
	-- 这张卡不能作为连接素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「闪刀」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索魔法卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡解放才能发动。「闪刀姬-零衣」「闪刀姬-露世」各1只从自己的卡组·墓地特殊召唤。那之后，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足属于「闪刀」魔法卡且可加入手牌条件的卡片
function s.filter(c)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ①号效果的检索发动检测与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己的卡组或墓地是否存在可以加入手牌的「闪刀」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，声明该效果包含将自己卡组或墓地中的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①号效果的效果处理函数（检索「闪刀」魔法卡）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组或墓地选择1张不受「王家之谷」影响的「闪刀」魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②号效果的发动代价检测与处理
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时，检测自身是否可解放且解放后有2个以上的空怪兽位
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c,tp)>1 end
	-- 解放自身作为效果发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤满足从自己卡组或墓地特殊召唤条件的「闪刀姬-零衣」
function s.spfilter1(c,e,tp)
	return c:IsCode(26077387) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足从自己卡组或墓地特殊召唤条件的「闪刀姬-露世」
function s.spfilter2(c,e,tp)
	return c:IsCode(37351133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤保证选择的卡片组中包含2张卡名不同的卡片
function s.fselect(g)
	return g:GetClassCount(Card.GetCode)==2
end
-- ②号效果的特殊召唤发动检测与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己的卡组或墓地是否存在可以特殊召唤的「闪刀姬-零衣」
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检测自己的卡组或墓地是否存在可以特殊召唤的「闪刀姬-露世」
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，声明该效果包含特殊召唤2张卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②号效果的效果处理函数（特殊召唤两只怪兽并可选破坏场上的一张卡）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取自己卡组和墓地中所有不受「王家之谷」影响且可特殊召唤的「闪刀姬-零衣」
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己卡组和墓地中所有不受「王家之谷」影响且可特殊召唤的「闪刀姬-露世」
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if #g1>=1 and #g2>=1 then
		g1:Merge(g2)
		local sg=g1:SelectSubGroup(tp,s.fselect,false,2,2)
		-- 判断这2只怪兽是否成功特殊召唤
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
			-- 检测场上是否存在可以作为破坏对象的卡片
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择执行卡片破坏的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选卡破坏？"
			-- 向选择破坏卡片的玩家提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上1张卡作为破坏的目标
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #dg>0 then
				-- 中断当前效果处理，使后续的破坏效果不与特殊召唤同时处理
				Duel.BreakEffect()
				-- 手动为选中的目标卡片显示被选为对象的动画效果
				Duel.HintSelection(dg)
				-- 因效果破坏选中的目标卡片
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end
