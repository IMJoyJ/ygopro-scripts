--光の波動
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己准备阶段，自己的场地区域没有「光之结界」存在的场合发动。进行1次投掷硬币，里出现的场合，这张卡的②③的效果直到下次的自己准备阶段无效化。
-- ②：自己场上的天使族怪兽的攻击力·守备力上升300。
-- ③：丢弃1张手卡才能发动。把2只卡名不同的「秘仪之力」怪兽从卡组加入手卡。这个回合，自己不是「秘仪之力」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 记录该卡拥有「光之结界」的卡名
	aux.AddCodeList(c,73206827)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段，自己的场地区域没有「光之结界」存在的场合发动。进行1次投掷硬币，里出现的场合，这张卡的②③的效果直到下次的自己准备阶段无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"掷硬币"
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上的天使族怪兽的攻击力·守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.upcon)
	-- 筛选目标为天使族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：丢弃1张手卡才能发动。把2只卡名不同的「秘仪之力」怪兽从卡组加入手卡。这个回合，自己不是「秘仪之力」怪兽不能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.thcost)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.toss_coin=true
-- 判断是否为自己的准备阶段且场地区域没有「光之结界」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段且场地区域没有「光之结界」
	return Duel.GetTurnPlayer()==tp and not Duel.IsEnvironment(73206827,tp,LOCATION_FZONE)
end
-- 设置投掷硬币效果的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置投掷硬币效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 处理投掷硬币效果，若为反面则标记效果无效
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 进行一次投掷硬币操作
	local coin=Duel.TossCoin(tp,1)
	if coin==0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_CLIENT_HINT,3,0,aux.Stringid(id,3))  --"①的效果（这张卡的②③的效果直到下次的自己准备阶段无效化）适用中"
	end
end
-- 判断是否为无效化状态
function s.upcon(e,c)
	return e:GetHandler():GetFlagEffect(id)==0
end
-- 丢弃一张手卡作为③效果的发动费用
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可丢弃的手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃一张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数，筛选「秘仪之力」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置③效果的处理目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的卡组卡片
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置③效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 处理③效果，若①效果生效则无效化此效果并返回，否则进行检索并设置不能特殊召唤的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 使连锁0的效果无效
		Duel.NegateEffect(0)
		return
	end
	-- 获取满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择2张不同卡名的「秘仪之力」怪兽
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,tg)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	end
	-- 设置不能特殊召唤「秘仪之力」以外怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非「秘仪之力」怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x5)
end
