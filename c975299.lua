--巨大要塞ゼロス
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「头目连战」加入手卡。
-- ②：自己场上的「巨大战舰」怪兽的攻击力·守备力上升500，不会被对方的效果破坏，对方不能把那些作为效果的对象。
-- ③：1回合1次，自己主要阶段才能发动。从手卡把1只「巨大战舰」怪兽特殊召唤。
-- ④：自己场上有「巨大战舰」怪兽召唤·特殊召唤的场合发动。给那些怪兽放置1个自身的效果使用的指示物。
function c975299.initial_effect(c)
	-- 记录该卡的效果中记载了卡号为66947414（头目连战）的卡片
	aux.AddCodeList(c,66947414)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「头目连战」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c975299.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「巨大战舰」怪兽的攻击力·守备力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出自己场上的「巨大战舰」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x15))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己场上的「巨大战舰」怪兽...不会被对方的效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出自己场上的「巨大战舰」怪兽
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x15))
	-- 设置不会被对方的效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ②：自己场上的「巨大战舰」怪兽...对方不能把那些作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出自己场上的「巨大战舰」怪兽
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x15))
	-- 设置不能成为对方的效果对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	-- ③：1回合1次，自己主要阶段才能发动。从手卡把1只「巨大战舰」怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(975299,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(c975299.sptg)
	e6:SetOperation(c975299.spop)
	c:RegisterEffect(e6)
	-- ④：自己场上有「巨大战舰」怪兽召唤·特殊召唤的场合发动。给那些怪兽放置1个自身的效果使用的指示物。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(975299,2))
	e7:SetCategory(CATEGORY_COUNTER)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCondition(c975299.ctcon)
	e7:SetTarget(c975299.cttg)
	e7:SetOperation(c975299.ctop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e8)
end
-- 过滤卡组中卡名为「头目连战」且能加入手卡的卡片
function c975299.thfilter(c)
	return c:IsCode(66947414) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理：可以从卡组把1张「头目连战」加入手卡
function c975299.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「头目连战」卡片
	local g=Duel.GetMatchingGroup(c975299.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在「头目连战」，则询问玩家是否将其加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(975299,0)) then  --"是否把「头目连战」加入手卡？"
		-- 提示玩家选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤手卡中可以特殊召唤的「巨大战舰」怪兽
function c975299.spfilter(c,e,tp)
	return c:IsSetCard(0x15) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检测
function c975299.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只可以特殊召唤的「巨大战舰」怪兽
		and Duel.IsExistingMatchingCard(c975299.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，准备从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的具体处理：从手卡特殊召唤1只「巨大战舰」怪兽
function c975299.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「巨大战舰」怪兽
	local g=Duel.SelectMatchingCard(tp,c975299.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出自己场上表侧表示的「巨大战舰」怪兽
function c975299.ctfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x15) and c:IsControler(tp)
end
-- 检查召唤·特殊召唤成功的怪兽中是否存在自己场上的「巨大战舰」怪兽
function c975299.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c975299.ctfilter,1,nil,tp)
end
-- 放置指示物效果的发动准备，计算需要放置指示物的怪兽数量并设置操作信息
function c975299.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=eg:FilterCount(c975299.ctfilter,nil,tp)
	-- 设置放置指示物的操作信息，准备给对应数量的怪兽放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ec,0,0x1f)
end
-- 放置指示物效果的具体处理：给召唤·特殊召唤成功的「巨大战舰」怪兽各放置1个指示物
function c975299.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c975299.ctfilter,nil,tp)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1f,1)
		tc=g:GetNext()
	end
end
