--竜星因士－セフィラツバーン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「星骑士」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「龙星因士-神数右枢」的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·灵摆召唤成功的场合，以这张卡以外的自己的怪兽区域·灵摆区域1张「星骑士」卡或者「神数」卡和对方场上1张表侧表示的卡为对象才能发动。那些卡破坏。
function c96223501.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「星骑士」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c96223501.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·反转召唤·灵摆召唤成功的场合，以这张卡以外的自己的怪兽区域·灵摆区域1张「星骑士」卡或者「神数」卡和对方场上1张表侧表示的卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,96223501)
	e3:SetTarget(c96223501.target)
	e3:SetOperation(c96223501.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c96223501.condition)
	c:RegisterEffect(e5)
	c96223501.star_knight_summon_effect=e3
end
-- 限制自己只能灵摆召唤「星骑士」怪兽以及「神数」怪兽
function c96223501.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9c,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判定这张卡是否是通过灵摆召唤特殊召唤成功
function c96223501.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤出场上表侧表示的「星骑士」卡或「神数」卡
function c96223501.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x9c,0xc4)
end
-- 过滤出场上表侧表示的卡
function c96223501.filter2(c)
	return c:IsFaceup()
end
-- 效果发动的对象选择与可行性检查
function c96223501.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己怪兽区域或灵摆区域是否存在除这张卡以外的1张表侧表示的「星骑士」卡或「神数」卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c96223501.filter1,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,e:GetHandler())
		-- 并且检查对方场上是否存在1张表侧表示的卡作为可选对象
		and Duel.IsExistingTarget(c96223501.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己怪兽区域或灵摆区域1张除这张卡以外的表侧表示的「星骑士」卡或「神数」卡作为对象
	local g1=Duel.SelectTarget(tp,c96223501.filter1,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,e:GetHandler())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的卡作为对象
	local g2=Duel.SelectTarget(tp,c96223501.filter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁处理的操作信息，表示将要破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理的执行函数，将选中的对象卡片破坏
function c96223501.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果将这些卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
