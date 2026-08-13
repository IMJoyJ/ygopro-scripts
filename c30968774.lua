--スワップリースト
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为连接素材送去墓地的场合才能发动。这张卡为连接素材的连接怪兽的攻击力下降500。那之后，自己从卡组抽1张。
function c30968774.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡作为连接素材送去墓地的场合才能发动。这张卡为连接素材的连接怪兽的攻击力下降500。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30968774,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,30968774)
	e1:SetCondition(c30968774.drcon)
	e1:SetTarget(c30968774.drtg)
	e1:SetOperation(c30968774.drop)
	c:RegisterEffect(e1)
	-- 为作为素材的这张卡与效果e1建立关联关系，使本卡作为连接素材时，效果能够关联到因它召唤的连接怪兽，从而可对其适用攻击力下降效果。
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 效果发动条件：这张卡位于墓地，且本次是被作为连接素材使用（r为REASON_LINK），满足“作为连接素材送去墓地的场合”。
function c30968774.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 效果发动时的目标设定：取得这张卡作为连接素材召唤的连接怪兽rc，并在可抽卡且rc与效果存在关联的前提下，将rc设为对象，同时登记抽卡的操作信息。
function c30968774.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	-- 发动合法性检查：玩家可以抽1张卡，且作为素材的连接怪兽rc与当前效果e保持关联。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and rc:IsRelateToEffect(e) end
	-- 将连接怪兽rc设置为当前连锁的对象，使后续处理能对这只怪兽下降攻击力。
	Duel.SetTargetCard(rc)
	-- 登记操作信息：本效果将进行抽卡，预计抽1张卡，用于系统对抽卡效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的操作：先取作为素材的连接怪兽，若其仍与连锁相关则使其攻击力下降500，并中断效果处理；随后自己抽1张卡，实现“下降攻击力”后“抽1张”的顺序。
function c30968774.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时被设定为对象的连接怪兽，即这张卡作为连接素材召唤出来的那只怪兽。
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToChain() then
		-- 这张卡为连接素材的连接怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
		-- 中断当前效果处理，使攻击力下降与抽卡效果视为不同时处理，以体现原文中“那之后”的先后关系。
		Duel.BreakEffect()
	end
	-- 自己从卡组抽1张卡，对应“那之后，自己从卡组抽1张”。
	Duel.Draw(tp,1,REASON_EFFECT)
end
