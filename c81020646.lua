--煉獄龍 オーガ・ドラグーン
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 自己手卡是0张的场合，1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c81020646.initial_effect(c)
	-- 为这张卡添加同调召唤手续，要求为暗属性调整加上调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 自己手卡是0张的场合，1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81020646,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c81020646.discon)
	e1:SetTarget(c81020646.distg)
	e1:SetOperation(c81020646.disop)
	c:RegisterEffect(e1)
end
-- 判定发动条件，确保自身未被战斗破坏、是对方发动效果、该发动可被无效且自己手卡为0张
function c81020646.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 判定发动的是魔法·陷阱卡的发动，该发动可以被无效，且自己手卡数量为0
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果发动的靶向处理，设置无效与破坏的操作信息
function c81020646.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 注册无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 注册破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理的执行，使发动无效并破坏
function c81020646.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否成功使发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
