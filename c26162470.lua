--飛竜戦艇－ファンドラ
-- 效果：
-- 这个卡名在规则上也当作「空牙团」卡使用。这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的「空牙团」怪兽的攻击力上升自己场上的「空牙团」怪兽种类×300。
-- ②：自己主要阶段才能发动。从卡组把1只「空牙团」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ③：自己场上的表侧表示的「空牙团」怪兽被对方的效果破坏的场合才能发动。从卡组把1只「空牙团」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的通用发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的「空牙团」怪兽的攻击力上升自己场上的「空牙团」怪兽种类×300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上的「空牙团」怪兽
	e2:SetTarget(aux.TargetBoolFunction(s.aufilter))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 自己主要阶段才能发动。从卡组把1只「空牙团」怪兽加入手卡。那之后，选自己1张手卡丢弃
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 自己场上的表侧表示的「空牙团」怪兽被对方的效果破坏的场合才能发动。从卡组把1只「空牙团」怪兽特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 判断是否为「空牙团」怪兽
function s.aufilter(c)
	return c:IsSetCard(0x114)
end
-- 判断是否为表侧表示的「空牙团」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 计算场上的「空牙团」怪兽数量并乘以300作为攻击力加成
function s.atkval(e)
	-- 获取场上的「空牙团」怪兽组
	local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)*300
end
-- 筛选可以加入手牌的「空牙团」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的处理条件和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 提示对方玩家选择了检索效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行检索效果的操作流程
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「空牙团」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并进入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认对方玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择满足条件的1张手牌丢弃
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 将选中的手牌送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 判断被破坏的怪兽是否为「空牙团」怪兽且为表侧表示
function s.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(0x114) and c:IsReason(REASON_EFFECT)
end
-- 判断是否满足特殊召唤的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.cfilter2,1,e:GetHandler(),tp)
end
-- 筛选可以特殊召唤的「空牙团」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理条件和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤的条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 提示对方玩家选择了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行特殊召唤效果的操作流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「空牙团」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
