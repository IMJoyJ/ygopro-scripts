--怒炎壊獣ドゴラン
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动（这个效果发动的回合，这张卡不能攻击）。对方场上的怪兽全部破坏。
function c93332803.initial_effect(c)
	-- 设置「坏兽」怪兽在自己场上只能有1只表侧表示存在（唯一存在限制）
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c93332803.spcon)
	e1:SetTarget(c93332803.sptg)
	e1:SetOperation(c93332803.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c93332803.spcon2)
	c:RegisterEffect(e2)
	-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动（这个效果发动的回合，这张卡不能攻击）。对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c93332803.descost)
	e3:SetTarget(c93332803.destg)
	e3:SetOperation(c93332803.desop)
	c:RegisterEffect(e3)
end
-- 过滤对方场上可作为特殊召唤规则解放的怪兽
function c93332803.spfilter(c,tp)
	-- 检查怪兽是否可以因特殊召唤而解放，且解放该怪兽后对方场上有可用的怪兽区域
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 检查手卡特殊召唤到对方场上的条件是否满足
function c93332803.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只满足解放条件的怪兽
	return Duel.IsExistingMatchingCard(c93332803.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 选择要解放的对方场上的怪兽
function c93332803.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足解放条件的怪兽
	local g=Duel.GetMatchingGroup(c93332803.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行解放对方场上怪兽的操作
function c93332803.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤场上表侧表示的「坏兽」怪兽
function c93332803.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 检查手卡特殊召唤到自己场上的条件是否满足
function c93332803.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有空余的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且对方场上存在表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c93332803.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 检查并执行去除坏兽指示物及不能攻击限制的发动代价
function c93332803.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从场上移去3个坏兽指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST)
		and e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 从场上移去3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
	-- 这个效果发动的回合，这张卡不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 检查并设置破坏对方场上全部怪兽的操作信息
function c93332803.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 注册破坏对方场上所有怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏对方场上全部怪兽的效果
function c93332803.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 破坏获取到的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
