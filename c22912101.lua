--サージ・ブリッツクリーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看，以场上1只怪兽为对象才能发动。那只怪兽破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把「浪涌雷盟兵」以外的1只「雷盟」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①的手卡特殊召唤·破坏效果，以及②的被破坏时的检索效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看，以场上1只怪兽为对象才能发动。那只怪兽破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把「浪涌雷盟兵」以外的1只「雷盟」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①的效果的发动代价：确认手卡中的这张卡未公开（给对方观看）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤可破坏怪兽，要求其被破坏离开场上后能留出可特殊召唤的怪兽区域
function s.desfilter(c,e,tp)
	-- 检查该怪兽离开怪兽区后是否有可用的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- 过滤手卡中可以进行特殊召唤的雷族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检查：进行对象合法性判定，并在发动时确认场上存在可破坏的怪兽以及手卡中存在可特殊召唤的雷族怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,e,tp) end
	-- 效果发动时，检查场上是否存在可以作为破坏对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp)
		-- 检查手卡中是否存在满足特殊召唤条件的雷族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置效果处理信息：破坏指定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的效果处理：破坏作为对象的怪兽，从手卡特殊召唤1只雷族怪兽，并注册本回合自己不能从手卡以外特殊召唤效果怪兽的玩家限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个（也是唯一的）对象卡（即要破坏的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)
		-- 成功破坏目标怪兽且自己场上有可用的怪兽区域
		and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡中选择1只满足特殊召唤条件的雷族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 洗切玩家的手牌（因手卡有变动/曾被观看）
			Duel.ShuffleHand(tp)
			-- 将选中的雷族怪兽以表侧表示特殊召唤到自己的场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把「浪涌雷盟兵」以外的1只「雷盟」怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动玩家注册该效果限制（即本回合不能从手卡以外特殊召唤效果怪兽）
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤的范围：限制除手卡以外的区域中特殊召唤的效果怪兽
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 过滤被效果破坏的卡
function s.cfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- ②效果的发动条件：场上有除了这张卡以外的卡被效果破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- 过滤卡组中可检索的「浪涌雷盟兵」以外的「雷盟」怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1df) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动准备与合法性检查：确认卡组存在符合条件的卡，并设置检索效果的卡片操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，检查卡组是否存在符合条件的「雷盟」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1只「浪涌雷盟兵」以外的「雷盟」怪兽加入手卡并让对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入到玩家的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
