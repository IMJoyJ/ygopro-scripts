--無限と有限のアルス＝マグナ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡除外才能发动。从卡组把1只战士族以外的「无垢大艺术」怪兽加入手卡。这个回合中，自己场上的「狱神」连接怪兽的原本攻击力变成3倍。
-- ②：这张卡是除外状态，融合·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
-- ③：自己场上有「狱神」连接怪兽存在的场合，以场上1只怪兽为对象才能发动。那只怪兽除外。
local s,id,o=GetID()
-- 初始化并注册这张卡的四个效果：①手卡除外的检索效果（一速起动，1回合1次）、②除外状态的自我特殊召唤诱发选发效果、③取对象除外怪兽的起动效果、以及③在受二速化效果影响时的诱发即时版本
function s.initial_effect(c)
	-- ①：把这张卡从手卡除外才能发动。从卡组把1只战士族以外的「无垢大艺术」怪兽加入手卡。这个回合中，自己场上的「狱神」连接怪兽的原本攻击力变成3倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡是除外状态，融合·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己场上有「狱神」连接怪兽存在的场合，以场上1只怪兽为对象才能发动。那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.rmcon2)
	c:RegisterEffect(e4)
end
-- ①效果的代价处理：发动时需把这张卡从手卡除外作为代价
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 把这张卡表侧表示除外，作为发动代价
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 检索过滤器：战士族以外的「无垢大艺术」怪兽，且可以加入手卡
function s.thfilter(c)
	return not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x1e6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的目标检查：确认卡组存在可检索的「无垢大艺术」怪兽，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动条件检查：自己卡组存在至少1只战士族以外的「无垢大艺术」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡（效果处理时才确定具体卡片）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选1只战士族以外的「无垢大艺术」怪兽加入手卡并给对方确认，然后注册一个到回合结束为止让自己场上「狱神」连接怪兽原本攻击力变成3倍的全场效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从卡组选择1只满足条件的「无垢大艺术」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g and g:GetCount()>0 then
		-- 把选择的卡以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合中，自己场上的「狱神」连接怪兽的原本攻击力变成3倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把攻击力3倍的全场效果注册给当前玩家，持续到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 攻击力变化效果的作用对象过滤器：自己场上的「狱神」连接怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 攻击力变化值：原本攻击力变成3倍
function s.atkval(e,c)
	return c:GetBaseAttack()*3
end
-- 触发过滤器：表侧表示的融合·连接怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_LINK)
end
-- ②效果的发动条件：本次特殊召唤的怪兽中存在融合·连接怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- ②效果的目标检查：确认自己怪兽区有空位且这张卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区存在可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计把这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：这张卡仍在连锁关系中的场合，把自己特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 条件过滤器：自己场上表侧表示的「狱神」连接怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- ③效果（一速起动版）的发动条件：未受二速化效果影响，且自己场上存在「狱神」连接怪兽
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前未受卡号37279096赋予的二速化效果影响
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 自己场上存在至少1只表侧表示的「狱神」连接怪兽
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③效果（二速诱发即时版）的发动条件：正受二速化效果影响，且自己场上存在「狱神」连接怪兽
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前正受卡号37279096赋予的二速化效果影响
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 自己场上存在至少1只表侧表示的「狱神」连接怪兽
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③效果的目标处理：以双方场上1只可以除外的怪兽为对象，并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动条件检查：双方场上存在至少1只可以除外并能成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择双方场上1只可以除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：预计把对象的1只怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果的处理：取得对象怪兽，若其仍在连锁关系中且为怪兽则将其除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 把对象怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
