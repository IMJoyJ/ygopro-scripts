--Flux Ochsenfeld
-- 效果：
-- 5星以上的地属性怪兽＋岩石族怪兽
-- 这张卡融合召唤的场合：可以从自己的手卡·墓地把「磁通量排斥者」以外的1只岩石族怪兽特殊召唤。
-- （诱发即时效果）：可以以自己场上1只地属性怪兽和对方场上1张卡为对象；那些卡回到持有者手卡。
-- 「磁通量排斥者」的每个效果1回合各能使用1次，不能在同一连锁上发动。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要满足matfilter1和matfilter2条件的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- 注册第一个效果：融合召唤成功时可以特殊召唤符合条件的岩石族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 注册第二个效果：可以将自己场上的地属性怪兽和对方场上的1张卡送回手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义融合素材1的过滤条件：地属性且等级5以上的怪兽
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(5)
end
-- 定义融合素材2的过滤条件：岩石族怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_ROCK)
end
-- 判断是否为融合召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义特殊召唤的过滤条件：非同名卡且为岩石族且可特殊召唤
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在符合条件的岩石族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查是否已使用过该效果
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 注册标识效果，防止同一连锁重复发动
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置操作信息，用于发动检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的岩石族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义返回手牌效果的过滤条件：表侧表示的地属性怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 设置返回手牌效果的发动条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在符合条件的地属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可送回手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查是否已使用过该效果
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 注册标识效果，防止同一连锁重复发动
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上的地属性怪兽
	local g1=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1张卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，用于发动检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 执行返回手牌操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的对象并筛选在场上的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 将符合条件的卡送回手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
