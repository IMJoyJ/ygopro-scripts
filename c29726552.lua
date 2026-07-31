--粘糸壊獣クモグス
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：对方对怪兽的召唤·特殊召唤成功时，把自己·对方场上2个坏兽指示物取除才能发动。直到下个回合的结束时，那些怪兽不能攻击，效果无效化。
function c29726552.initial_effect(c)
	-- 设置该卡在怪兽区内存在唯一性，使用辅助函数过滤坏兽卡组。
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
-- 定义一个过滤函数，用于检查卡片是否可以解放以及对方怪兽区是否有空位。
function c29726552.spfilter(c,tp)
	-- 返回卡片是否可被解放且对方怪兽区有空位
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 定义特殊召唤的条件，如果存在满足spfilter条件的卡牌则返回true。
function c29726552.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足过滤条件的卡牌
	return Duel.IsExistingMatchingCard(c29726552.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 设置特殊召唤的目标，获取满足spfilter条件的卡组，提示选择要解放的卡片，并设置目标卡片。
function c29726552.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足spfilter条件的卡组
	local g=Duel.GetMatchingGroup(c29726552.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤的操作，释放选定的卡片。
function c29726552.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 释放目标卡牌
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义一个过滤函数，用于检查卡片是否为表侧表示且属于坏兽卡组。
function c29726552.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 定义特殊召唤的条件2，如果手牌存在怪兽并且对方场上存在表侧表示的坏兽则返回true。
function c29726552.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的坏兽卡
		and Duel.IsExistingMatchingCard(c29726552.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义一个过滤函数，用于检查卡片是否为我方召唤且表侧表示。
function c29726552.filter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 定义效果的代价，如果可以移除2个坏兽指示物则移除。
function c29726552.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 移除坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 定义效果的目标，检查对方场上是否存在召唤成功的怪兽，并设置目标卡片。
function c29726552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c29726552.filter,1,nil,1-tp) and not eg:IsContains(e:GetHandler()) end
	local g=eg:Filter(c29726552.filter,nil,1-tp)
	-- 设置目标卡牌
	Duel.SetTargetCard(g)
end
-- 定义效果的操作，对目标怪兽附加不能攻击、效果无效化的效果。
function c29726552.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁发动的对象卡组，并过滤出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 给目标怪兽添加不能攻击的效果，并在回合结束时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 给目标怪兽添加使效果无效化的效果，并在回合结束时重置。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		-- 给目标怪兽添加禁用效果的效果，并在回合结束时重置。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
