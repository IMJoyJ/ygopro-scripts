--フルール・ド・シュヴァリエ
-- 效果：
-- 「鲜花同调士」＋调整以外的怪兽1只以上
-- ①：1回合1次，自己回合对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c45037489.initial_effect(c)
	-- 为怪兽添加允许使用的素材代码列表，此处指定只能使用代码为19642774的卡作为素材
	aux.AddMaterialCodeList(c,19642774)
	-- 设置该怪兽的同调召唤手续，要求1只满足tfilter条件的调整和1只以上满足aux.NonTuner条件的怪兽作为素材
	aux.AddSynchroProcedure(c,c45037489.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己回合对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45037489,0))  --"魔法·陷阱卡的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c45037489.discon)
	e1:SetTarget(c45037489.distg)
	e1:SetOperation(c45037489.disop)
	c:RegisterEffect(e1)
end
c45037489.material_setcode=0x1017
-- 定义同调召唤中调整的过滤条件，即卡牌代码为19642774或具有效果20932152的怪兽
function c45037489.tfilter(c)
	return c:IsCode(19642774) or c:IsHasEffect(20932152)
end
-- 设置效果发动的条件，判断是否满足发动时机、是否为对方回合、是否为魔法·陷阱卡发动且该连锁可无效
function c45037489.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该怪兽未在战斗中被破坏，且为对方回合，且为己方回合玩家
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and tp==Duel.GetTurnPlayer()
		-- 判断发动的为魔法·陷阱卡且该连锁可被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 设置效果的发动目标，确定连锁发动无效和破坏的效果处理对象
function c45037489.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的效果信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁发动破坏的效果信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 设置效果的发动处理，使连锁发动无效并破坏对应卡
function c45037489.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发动是否成功无效且对应卡仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对应卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
