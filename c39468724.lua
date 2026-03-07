--アラドヴァルの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除10星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。自己的手卡·场上最多2只「影灵衣」怪兽解放，把那个数量的「影灵衣」卡从卡组送去墓地。
-- ②：怪兽的效果发动时，把自己的手卡·场上1只怪兽解放才能发动。那个发动无效并除外。
function c39468724.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以只使用除10星以外的怪兽来作的仪式召唤则不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡必须通过仪式召唤特殊召唤，且不能被无效或复制
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。自己的手卡·场上最多2只「影灵衣」怪兽解放，把那个数量的「影灵衣」卡从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39468724,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,39468724)
	e2:SetCost(c39468724.tgcost)
	e2:SetTarget(c39468724.tgtg)
	e2:SetOperation(c39468724.tgop)
	c:RegisterEffect(e2)
	-- ②：怪兽的效果发动时，把自己的手卡·场上1只怪兽解放才能发动。那个发动无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39468724,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,39468725)
	e3:SetCondition(c39468724.negcon)
	e3:SetCost(c39468724.negcost)
	-- 设置效果目标为使发动无效并除外
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c39468724.negop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断怪兽是否不是10星
function c39468724.mat_filter(c)
	return not c:IsLevel(10)
end
-- 效果发动时，将此卡从手卡丢弃作为代价
function c39468724.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡送去墓地作为支付代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断是否为「影灵衣」怪兽
function c39468724.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xb4)
end
-- 过滤函数，用于判断是否为「影灵衣」且可送去墓地的卡
function c39468724.tgfilter(c)
	return c:IsSetCard(0xb4) and c:IsAbleToGrave()
end
-- 设置效果目标，检查是否满足发动条件
function c39468724.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「影灵衣」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39468724.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己手卡或场上是否存在至少1只「影灵衣」怪兽可解放
		and Duel.CheckReleaseGroupEx(tp,c39468724.filter,1,REASON_EFFECT,true,e:GetHandler()) end
	-- 设置连锁操作信息，表示将要将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将卡送去墓地的操作
function c39468724.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中「影灵衣」卡的数量
	local ct=Duel.GetMatchingGroupCount(c39468724.tgfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 then ct=1 end
	if ct>2 then ct=2 end
	-- 选择最多满足数量的「影灵衣」怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,c39468724.filter,1,ct,REASON_EFFECT,true,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽解放
		local rct=Duel.Release(g,REASON_EFFECT)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择与解放数量相同的「影灵衣」卡送去墓地
		local tg=Duel.SelectMatchingCard(tp,c39468724.tgfilter,tp,LOCATION_DECK,0,rct,rct,nil)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
-- 效果发动时的条件判断函数
function c39468724.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认此卡未在战斗中被破坏，且连锁可被无效，且发动的是怪兽效果
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 效果发动时，将场上或手卡的1只怪兽解放作为代价
function c39468724.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只怪兽作为代价
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_COST,true,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_COST,true,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果处理函数，使发动无效并除外
function c39468724.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效并确认效果相关卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将连锁中被无效的卡除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
