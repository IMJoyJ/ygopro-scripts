--ネフティスの祀り手
-- 效果：
-- 「奈芙提斯的轮回」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1只「奈芙提斯」怪兽特殊召唤。这个效果发动的回合的结束阶段这张卡破坏。
-- ②：这张卡在墓地存在的场合才能发动。选手卡1张「奈芙提斯」卡破坏，这张卡从墓地特殊召唤。
function c88176533.initial_effect(c)
	aux.AddCodeList(c,23459650)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1只「奈芙提斯」怪兽特殊召唤。这个效果发动的回合的结束阶段这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88176533,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,88176533)
	e1:SetCondition(c88176533.spcon1)
	e1:SetTarget(c88176533.sptg1)
	e1:SetOperation(c88176533.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合才能发动。选手卡1张「奈芙提斯」卡破坏，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88176533,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,88176534)
	e2:SetTarget(c88176533.sptg2)
	e2:SetOperation(c88176533.spop2)
	c:RegisterEffect(e2)
end
-- 检查此卡是否是通过仪式召唤特殊召唤成功的
function c88176533.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤卡组中可以特殊召唤的「奈芙提斯」怪兽
function c88176533.spfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查
function c88176533.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「奈芙提斯」怪兽
		and Duel.IsExistingMatchingCard(c88176533.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理逻辑，包含注册结束阶段破坏自身的效果以及从卡组特殊召唤怪兽
function c88176533.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果发动的回合的结束阶段这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c88176533.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 如果此时自己场上没有可用的怪兽区域，则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「奈芙提斯」怪兽
	local g=Duel.SelectMatchingCard(tp,c88176533.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 结束阶段破坏自身的效果处理函数
function c88176533.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 效果②的发动准备与合法性检查
function c88176533.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡中是否存在「奈芙提斯」卡片
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x11f) end
	-- 设置连锁信息，表示该效果包含破坏手卡中1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 设置连锁信息，表示该效果包含特殊召唤此卡自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理逻辑，包含破坏手卡中的「奈芙提斯」卡并特殊召唤自身
function c88176533.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从手卡选择1张「奈芙提斯」卡片
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,nil,0x11f)
	-- 如果成功选择并破坏了手卡中的卡片
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) then
		-- 将此卡从墓地表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
