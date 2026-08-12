--巨大戦艦 ビッグ・コアMk－Ⅲ
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。给这张卡放置3个指示物。
-- ③：这张卡不会被战斗破坏。
-- ④：这张卡进行战斗的伤害步骤结束时发动。这张卡1个指示物取除。不能取除的场合，这张卡破坏。
-- ⑤：把墓地的这张卡除外才能发动。自己墓地的「巨大战舰」怪兽全部回到卡组。
function c82821760.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c82821760.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。给这张卡放置3个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82821760,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c82821760.cttg)
	e2:SetOperation(c82821760.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 注册巨大战舰系列通用的战斗后移除指示物或破坏的效果
	aux.EnableBESRemove(c)
	-- ⑤：把墓地的这张卡除外才能发动。自己墓地的「巨大战舰」怪兽全部回到卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(82821760,2))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	-- 设置发动代价为将墓地的这张卡除外
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(c82821760.tdtg)
	e6:SetOperation(c82821760.tdop)
	c:RegisterEffect(e6)
end
-- 特殊召唤规则的条件判定函数
function c82821760.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在怪兽（数量为0）
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在怪兽（数量大于0）
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 放置指示物效果的发动准备与效果信息设置
function c82821760.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为放置3个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 放置指示物效果的实际处理函数
function c82821760.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
-- 过滤自己墓地中可以回到卡组的「巨大战舰」怪兽
function c82821760.tdfilter(c)
	return c:IsSetCard(0x15) and c:IsAbleToDeck()
end
-- 回到卡组效果的发动准备与合法性检测
function c82821760.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己墓地是否存在至少1张除这张卡以外的「巨大战舰」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82821760.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 获取自己墓地中除这张卡以外的所有「巨大战舰」怪兽
	local g=Duel.GetMatchingGroup(c82821760.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 设置效果处理信息为将这些怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 回到卡组效果的实际处理函数
function c82821760.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有的「巨大战舰」怪兽
	local g=Duel.GetMatchingGroup(c82821760.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 进行王家之谷的无效化检测
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将目标怪兽全部送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
