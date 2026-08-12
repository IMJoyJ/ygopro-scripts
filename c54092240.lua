--テセア聖霊器
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把有「勇者衍生物」的衍生物名记述的手卡1张卡给对方观看才能发动。把通常魔法卡以外的有「勇者衍生物」的衍生物名记述的1张魔法卡从卡组加入手卡。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。
function c54092240.initial_effect(c)
	-- 注册卡片记述了「勇者衍生物」的卡片密码
	aux.AddCodeList(c,3285552)
	-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54092240,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,54092240)
	e1:SetCondition(c54092240.sscon)
	e1:SetTarget(c54092240.sstg)
	e1:SetOperation(c54092240.ssop)
	c:RegisterEffect(e1)
	-- ②：把有「勇者衍生物」的衍生物名记述的手卡1张卡给对方观看才能发动。把通常魔法卡以外的有「勇者衍生物」的衍生物名记述的1张魔法卡从卡组加入手卡。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54092240,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,54092241)
	e2:SetCost(c54092240.thcost)
	e2:SetTarget(c54092240.thtg)
	e2:SetOperation(c54092240.thop)
	c:RegisterEffect(e2)
	-- 注册用于检测特殊召唤限制的自定义活动计数器
	Duel.AddCustomActivityCounter(54092240,ACTIVITY_SPSUMMON,c54092240.counterfilter)
end
-- 定义计数器过滤函数，用于检测特殊召唤的怪兽是否为「勇者衍生物」或记述了「勇者衍生物」
function c54092240.counterfilter(c)
	-- 检查怪兽是否为「勇者衍生物」或其卡名记述了「勇者衍生物」
	return aux.IsCodeOrListed(c,3285552)
end
-- 定义过滤函数：场上表侧表示的「勇者衍生物」
function c54092240.cfilter(c)
	return c:IsFaceup() and c:IsCode(3285552)
end
-- 定义效果①的发动条件函数
function c54092240.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「勇者衍生物」
	return Duel.IsExistingMatchingCard(c54092240.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义效果①的发动准备函数
function c54092240.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果①的处理函数
function c54092240.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义过滤函数：手牌中记述了「勇者衍生物」且未给对方观看的卡
function c54092240.thcfilter(c)
	-- 检查卡片是否记述了「勇者衍生物」且未处于公开状态
	return aux.IsCodeListed(c,3285552) and not c:IsPublic()
end
-- 定义效果②的发动代价函数
function c54092240.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未进行过不符合限制条件的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(54092240,tp,ACTIVITY_SPSUMMON)==0
		-- 检查手牌中是否存在可用于展示的记述了「勇者衍生物」的卡
		and Duel.IsExistingMatchingCard(c54092240.thcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌选择1张记述了「勇者衍生物」的卡
	local g=Duel.SelectMatchingCard(tp,c54092240.thcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。把通常魔法卡以外的有「勇者衍生物」的衍生物名记述的1张魔法卡从卡组加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c54092240.splimit)
	-- 注册不能特殊召唤特定怪兽以外怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制函数：不能特殊召唤非「勇者衍生物」且未记述「勇者衍生物」的怪兽
function c54092240.splimit(e,c)
	return not c54092240.counterfilter(c)
end
-- 定义过滤函数：卡组中通常魔法以外的、记述了「勇者衍生物」且能加入手牌的魔法卡
function c54092240.thfilter(c)
	-- 检查卡片是否为魔法卡、非通常魔法、记述了「勇者衍生物」且能加入手牌
	return c:IsType(TYPE_SPELL) and c:GetType()~=TYPE_SPELL and aux.IsCodeListed(c,3285552) and c:IsAbleToHand()
end
-- 定义效果②的发动准备函数
function c54092240.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54092240.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的处理函数
function c54092240.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c54092240.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
