--ゴーティスの守人イーノック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己的除外状态的1只4星以下的鱼族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：从自己的手卡·场上（表侧表示）把1只鱼族怪兽除外才能发动。从卡组把1张「魊影」陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册此卡召唤成功时发动的效果①，并克隆注册特殊召唤成功时发动的效果①，以及在场上发动的起动效果②。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以自己的除外状态的1只4星以下的鱼族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·场上（表侧表示）把1只鱼族怪兽除外才能发动。从卡组把1张「魊影」陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：除外状态的表侧表示、4星以下、可以特殊召唤的鱼族怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_FISH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备：检查是否满足发动条件，并选择除外状态的1只4星以下鱼族怪兽作为效果对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外状态中是否存在满足条件的鱼族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外状态的1只满足条件的鱼族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：包含特殊召唤分类，操作数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理：将作为对象的怪兽守备表示特殊召唤，并将其效果无效化
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则尝试将其以表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 过滤条件：手卡或场上表侧表示的、可以作为代价除外的鱼族怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从自己的手卡或场上（表侧表示）选择1只鱼族怪兽除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可作为代价除外的鱼族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只手卡或场上表侧表示的鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的「魊影」陷阱卡
function s.filter(c)
	return c:IsSetCard(0x18a) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的「魊影」陷阱卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可检索的「魊影」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：包含检索/加入手牌分类，操作数量为1，目标位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1张「魊影」陷阱卡加入手卡，并向对方展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「魊影」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
