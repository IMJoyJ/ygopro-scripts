--U.A.ドレッドノートダンカー
-- 效果：
-- 「超级运动员 无畏扣篮手」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 无畏扣篮手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡给与对方战斗伤害时，以场上1张卡为对象才能发动。那张卡破坏。
function c71279983.initial_effect(c)
	-- 「超级运动员 无畏扣篮手」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 无畏扣篮手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,71279983+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c71279983.spcon)
	e1:SetTarget(c71279983.sptg)
	e1:SetOperation(c71279983.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：这张卡给与对方战斗伤害时，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c71279983.descon)
	e3:SetTarget(c71279983.destg)
	e3:SetOperation(c71279983.desop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「超级运动员 无畏扣篮手」以外的「超级运动员」怪兽，且能返回手牌，并且其离开后能腾出可用的怪兽区域
function c71279983.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(71279983) and c:IsAbleToHandAsCost()
		-- 检查该怪兽返回手牌后，是否能腾出可用的怪兽区域以供特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的出现条件：自己场上存在至少1只满足过滤条件的怪兽
function c71279983.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c71279983.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的准备阶段：让玩家选择1只满足过滤条件的怪兽，并将其作为标签对象保存
function c71279983.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c71279983.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送提示信息：“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行阶段：将选中的怪兽返回手牌
function c71279983.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽因特殊召唤的规则返回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 效果发动的条件：给与对方玩家战斗伤害时
function c71279983.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标选择与操作信息注册：选择场上1张卡作为对象，并注册破坏的操作信息
function c71279983.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：破坏1张选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的执行阶段：若对象卡片仍存在于场上，则将其破坏
function c71279983.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
