--覚星輝士－セフィラビュート
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「星骑士」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「觉星辉士-神数蝇王」的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·灵摆召唤成功的场合，以这张卡以外的自己的怪兽区域·灵摆区域1张「星骑士」卡或者「神数」卡和对方场上盖放的1张卡为对象才能发动。那些卡破坏。
function c22617205.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「星骑士」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c22617205.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·反转召唤·灵摆召唤成功的场合，以这张卡以外的自己的怪兽区域·灵摆区域1张「星骑士」卡或者「神数」卡和对方场上盖放的1张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,22617205)
	e3:SetTarget(c22617205.target)
	e3:SetOperation(c22617205.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c22617205.condition)
	c:RegisterEffect(e5)
	c22617205.star_knight_summon_effect=e3
end
-- 限制非「星骑士」或「神数」怪兽不能进行灵摆召唤
function c22617205.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9c,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判断此卡是否为灵摆召唤成功
function c22617205.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 筛选场上正面表示的「星骑士」或「神数」怪兽
function c22617205.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x9c,0xc4)
end
-- 筛选场上背面表示的卡
function c22617205.filter2(c)
	return c:IsFacedown()
end
-- 设置效果发动时的选择目标条件
function c22617205.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择「星骑士」或「神数」怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c22617205.filter1,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,e:GetHandler())
		-- 判断是否满足选择对方场上盖放卡的条件
		and Duel.IsExistingTarget(c22617205.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的「星骑士」或「神数」怪兽
	local g1=Duel.SelectTarget(tp,c22617205.filter1,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,e:GetHandler())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上盖放的一张卡
	local g2=Duel.SelectTarget(tp,c22617205.filter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 执行效果破坏操作
function c22617205.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡组中的卡以效果原因进行破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
