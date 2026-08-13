--フルール・ド・シュヴァリエ
-- 效果：
-- 「鲜花同调士」＋调整以外的怪兽1只以上
-- ①：1回合1次，自己回合对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c45037489.initial_effect(c)
	-- 将卡名“鲜花同调士”（密码19642774）登记为这张卡的同调素材候补卡名，用于素材相关判定。
	aux.AddMaterialCodeList(c,19642774)
	-- 为鲜花骑士添加同调召唤手续：调整素材必须满足tfilter（即“鲜花同调士”或持有替代效果的卡），调整以外的怪兽任意且至少1只，对应“鲜花同调士＋调整以外的怪兽1只以上”。
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
-- 同调素材中调整部分的过滤条件：卡名是“鲜花同调士”（19642774），或者拥有效果编号20932152的替代素材效果。
function c45037489.tfilter(c)
	return c:IsCode(19642774) or c:IsHasEffect(20932152)
end
-- 效果①的发动条件：此卡不在战斗破坏确定状态，且对方发动魔法·陷阱卡的卡的发动，且当前是自己的回合，且该连锁可以被无效。
function c45037489.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡不在战斗破坏确定状态、对方是效果发动者、自己（效果持有者）是当前回合玩家。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and tp==Duel.GetTurnPlayer()
		-- 判断对方发动的效果是魔法·陷阱卡的卡的发动，并且该连锁可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果①发动时的目标/操作信息设定：将对方发动的那张魔法·陷阱卡设为无效对象；若其可破坏且与发动效果关联，则同时设为破坏对象。
function c45037489.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁中对方发动的魔法·陷阱卡（eg）标记为将被无效的对象，操作信息分类为CATEGORY_NEGATE。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 将这张魔法·陷阱卡（eg）标记为将被破坏的对象，操作信息分类为CATEGORY_DESTROY。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的处理：先无效那个连锁中的魔法·陷阱卡的发动；若无效成功且该卡仍与效果关联，则将其破坏。
function c45037489.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功，并且被无效的那张卡仍然与当前效果关联，未被其他效果转移或离场。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏eg，即那张被无效的魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
