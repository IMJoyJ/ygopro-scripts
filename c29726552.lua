--粘糸壊獣クモグス
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：对方对怪兽的召唤·特殊召唤成功时，把自己·对方场上2个坏兽指示物取除才能发动。直到下个回合的结束时，那些怪兽不能攻击，效果无效化。
function c29726552.initial_effect(c)
	-- 设置卡片在场上的唯一性，确保场上只能存在1只表侧表示的「坏兽」怪兽
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
-- 定义特殊召唤时可解放的怪兽过滤条件：满足条件的怪兽可被解放用于特殊召唤
function c29726552.spfilter(c,tp)
	-- 满足条件的怪兽可被解放用于特殊召唤
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断是否满足特殊召唤条件①：检查对方场上是否存在可解放的怪兽
function c29726552.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在可解放的怪兽
	return Duel.IsExistingMatchingCard(c29726552.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 设置特殊召唤时选择解放怪兽的处理流程
function c29726552.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(c29726552.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c29726552.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽解放用于特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义「坏兽」怪兽的过滤条件：必须表侧表示且为「坏兽」种族
function c29726552.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 判断是否满足特殊召唤条件②：检查己方场上是否存在「坏兽」怪兽且有空怪兽区
function c29726552.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方场上是否有空怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c29726552.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义召唤成功时目标怪兽的过滤条件：必须是己方召唤的表侧表示怪兽
function c29726552.filter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 设置发动效果时的费用：移除自己和对方场上的2个坏兽指示物
function c29726552.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个坏兽指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 移除自己和对方场上的2个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 设置发动效果时的目标选择流程：选择对方召唤成功的表侧表示怪兽
function c29726552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c29726552.filter,1,nil,1-tp) and not eg:IsContains(e:GetHandler()) end
	local g=eg:Filter(c29726552.filter,nil,1-tp)
	-- 将目标怪兽设置为连锁对象
	Duel.SetTargetCard(g)
end
-- 执行效果处理：使目标怪兽不能攻击、效果无效化
function c29726552.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中目标怪兽组中与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		-- 使目标怪兽效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
