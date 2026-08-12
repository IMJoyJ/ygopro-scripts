--粘糸壊獣クモグス
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：对方对怪兽的召唤·特殊召唤成功时，把自己·对方场上2个坏兽指示物取除才能发动。直到下个回合的结束时，那些怪兽不能攻击，效果无效化。
function c29726552.initial_effect(c)
	-- 设置场上唯一规则：自己场上只能有1只表侧表示的「坏兽」怪兽存在
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c29726552.spcon)
	e1:SetTarget(c29726552.sptg)
	e1:SetOperation(c29726552.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c29726552.spcon2)
	c:RegisterEffect(e2)
	-- ④：对方对怪兽的召唤·特殊召唤成功时，把自己·对方场上2个坏兽指示物取除才能发动。直到下个回合的结束时，那些怪兽不能攻击，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c29726552.cost)
	e3:SetTarget(c29726552.target)
	e3:SetOperation(c29726552.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
c29726552.mentioned_counter={
	[0x37]=true,
}
-- 定义过滤函数：判断对方场上可被解放且解放后对方场上仍有可用怪兽区的怪兽
function c29726552.spfilter(c,tp)
	-- 检查该怪兽是否能以特殊召唤为由被解放，且将其解放后对方场上还有可用的怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- ①效果特殊召唤的发动条件：对方场上存在至少1只满足解放条件的怪兽
function c29726552.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只可以解放且解放后有空余怪兽区的怪兽
	return Duel.IsExistingMatchingCard(c29726552.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- ①效果特殊召唤的目标选择处理：让对方选择1只要解放的怪兽
function c29726552.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得对方场上全部满足解放条件的怪兽组
	local g=Duel.GetMatchingGroup(c29726552.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家「请选择要解放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①效果特殊召唤的处理：解放之前选择的对方怪兽
function c29726552.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的对方怪兽以特殊召唤为由解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义过滤函数：判断是否为表侧表示的「坏兽」怪兽
function c29726552.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- ②效果特殊召唤的发动条件：自己场上有空怪兽区且对方场上有「坏兽」怪兽
function c29726552.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否还有可用的主要怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c29726552.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义过滤函数：判断是否为对方召唤·特殊召唤的表侧表示怪兽
function c29726552.filter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- ④效果的代价：取除自己·对方场上2个坏兽指示物
function c29726552.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己·对方场上是否可以以代价取除2个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 作为发动代价取除自己·对方场上2个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- ④效果的对象设定：把对方召唤·特殊召唤的那些怪兽设为此连锁的对象
function c29726552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c29726552.filter,1,nil,1-tp) and not eg:IsContains(e:GetHandler()) end
	local g=eg:Filter(c29726552.filter,nil,1-tp)
	-- 将满足条件的对方召唤怪兽组设置为当前连锁的对象
	Duel.SetTargetCard(g)
end
-- ④效果的处理：对那些怪兽适用不能攻击和效果无效化，直到下个回合的结束
function c29726552.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象中仍与这个效果关联的怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 直到下个回合的结束时，那些怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 直到下个回合的结束时，那些怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		-- 直到下个回合的结束时，那些怪兽效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
