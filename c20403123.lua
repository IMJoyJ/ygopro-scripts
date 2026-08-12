--EMスライハンド・マジシャン
-- 效果：
-- ①：这张卡可以把灵摆怪兽以外的自己场上1只「娱乐伙伴」怪兽解放从手卡特殊召唤。
-- ②：1回合1次，丢弃1张手卡，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
function c20403123.initial_effect(c)
	-- ①：这张卡可以把灵摆怪兽以外的自己场上1只「娱乐伙伴」怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c20403123.hspcon)
	e1:SetTarget(c20403123.hsptg)
	e1:SetOperation(c20403123.hspop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，丢弃1张手卡，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20403123,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c20403123.descost)
	e2:SetTarget(c20403123.destg)
	e2:SetOperation(c20403123.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否满足特殊召唤条件的「娱乐伙伴」怪兽
function c20403123.hspfilter(c,tp)
	return c:IsSetCard(0x9f) and not c:IsType(TYPE_PENDULUM)
		-- 判断目标怪兽是否在场上且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足特殊召唤条件
function c20403123.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c20403123.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择并设置要解放的怪兽
function c20403123.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c20403123.hspfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作
function c20403123.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽以特殊召唤理由进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 支付效果代价，丢弃一张手卡
function c20403123.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张手卡作为效果代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断目标是否为表侧表示的卡
function c20403123.filter(c)
	return c:IsFaceup()
end
-- 设置破坏效果的目标
function c20403123.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c20403123.filter(chkc) end
	-- 检查场上是否存在满足条件的可破坏对象
	if chk==0 then return Duel.IsExistingTarget(c20403123.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c20403123.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c20403123.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
