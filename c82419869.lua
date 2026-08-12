--U.A.パーフェクトエース
-- 效果：
-- 「超级运动员 完美王牌投手」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 完美王牌投手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：对方回合1次，魔法·陷阱·怪兽的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
function c82419869.initial_effect(c)
	-- 「超级运动员 完美王牌投手」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 完美王牌投手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82419869+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c82419869.spcon)
	e1:SetTarget(c82419869.sptg)
	e1:SetOperation(c82419869.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，魔法·陷阱·怪兽的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82419869,0))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c82419869.discon)
	e2:SetCost(c82419869.discost)
	e2:SetTarget(c82419869.distg)
	e2:SetOperation(c82419869.disop)
	c:RegisterEffect(e2)
end
-- 过滤特殊召唤规则所需的怪兽：自己场上表侧表示的「超级运动员 完美王牌投手」以外的「超级运动员」怪兽，且能返回手牌，并且该怪兽离开后有可用的怪兽区域
function c82419869.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(82419869) and c:IsAbleToHandAsCost()
		-- 检查该怪兽离开场上后，自己场上是否有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定：自己场上是否存在满足特殊召唤过滤条件的怪兽
function c82419869.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足特殊召唤过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c82419869.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的目标选择：让玩家选择1只满足条件的怪兽，并将其记录在效果对象中
function c82419869.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c82419869.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送提示信息，要求选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作：将选中的怪兽返回手牌，从而完成这张卡的特殊召唤
function c82419869.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的代替代价（或方式）送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 效果②的发动条件判定：自身未被战斗破坏，且当前处于对方回合，且有可以被无效的效果发动
function c82419869.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查当前连锁的效果发动是否可以被无效，并且当前回合不是自己的回合（即对方回合）
	return Duel.IsChainNegatable(ev) and Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动代价处理：检查并丢弃1张手牌
function c82419869.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查自己手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的目标判定：设置效果无效和破坏的操作信息
function c82419869.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使该效果的发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动的卡可以被破坏且仍与效果相关联，则设置操作信息为“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的效果处理：使发动无效并破坏
function c82419869.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该效果的发动无效，并且该卡在场上或与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
