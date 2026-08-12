--フラックス・オクセンフェルト
-- 效果：
-- 5星以上的地属性怪兽＋岩石族怪兽
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：这张卡融合召唤的场合才能发动。从自己的手卡·墓地把「磁通之奥克森菲尔德」以外的1只岩石族怪兽特殊召唤。
-- ②：自己·对方回合，以自己场上1只地属性怪兽和对方场上1张卡为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制，添加融合召唤手续，并注册①特殊召唤效果和②回到手卡效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：用满足matfilter1（5星以上地属性）与matfilter2（岩石族）的怪兽各1只作为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡融合召唤的场合才能发动。从自己的手卡·墓地把「磁通之奥克森菲尔德」以外的1只岩石族怪兽特殊召唤。
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
	-- 这个卡名的②的效果1回合只能使用1次，同一连锁上不能发动。②：自己·对方回合，以自己场上1只地属性怪兽和对方场上1张卡为对象才能发动。那些卡回到手卡。
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
-- 融合素材过滤条件1：5星以上的地属性怪兽
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(5)
end
-- 融合素材过滤条件2：岩石族怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_ROCK)
end
-- ①效果发动条件：这张卡是融合召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤对象过滤条件：不是「磁通之奥克森菲尔德」、岩石族且可以被特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时检查：自己怪兽区有空位、手卡·墓地存在可特殊召唤的岩石族怪兽、且本连锁上②效果未使用过（同一连锁上不能发动）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己手卡·墓地存在满足条件的可特殊召唤的岩石族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 确认本连锁上没有发动过②效果（同一连锁上不能发动）
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 为玩家注册本连锁已发动①效果的标识，用于阻止同一连锁上再发动②效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置操作信息：从手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：从自己的手卡·墓地选1只「磁通之奥克森菲尔德」以外的岩石族怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送请选择要特殊召唤的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1只满足条件且不受王家长眠之谷影响的岩石族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果自己场上对象过滤条件：表侧表示的地属性且可以回到手卡的怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- ②效果发动时检查：自己场上存在地属性怪兽、对方场上存在可回手卡的卡、且本连锁上①效果未使用过（同一连锁上不能发动）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 确认自己怪兽区存在可作为对象的表侧表示地属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 确认对方场上存在可作为对象的可以回到手卡的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
		-- 确认本连锁上没有发动过①效果（同一连锁上不能发动）
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册本连锁已发动②效果的标识，用于阻止同一连锁上再发动①效果
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 向玩家发送请选择要返回手牌的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 以自己场上1只表侧表示的地属性怪兽为对象
	local g1=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家发送请选择要返回手牌的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 以对方场上1张可以回到手卡的卡为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：将2张作为对象的卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果处理：将作为对象的仍在场上的卡回到持有者手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象卡中仍在场上的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 将那些卡以效果原因回到持有者的手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
