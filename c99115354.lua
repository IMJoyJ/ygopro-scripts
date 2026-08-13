--ハイパーサイコライザー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，持有比这张卡的攻击力低的攻击力的怪兽不能攻击，持有比这张卡的攻击力高的攻击力的场上的怪兽不能把效果发动。
-- ②：这张卡被对方破坏送去墓地的场合，以自己墓地的种族和属性是相同的1只调整和1只调整以外的怪兽为对象才能发动。那些怪兽加入手卡。
function c99115354.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽（无额外限制）和1只以上调整以外的怪兽作为素材进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- “只要这张卡在怪兽区域存在，持有比这张卡的攻击力低的攻击力的怪兽不能攻击”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c99115354.atktg)
	c:RegisterEffect(e1)
	-- “持有比这张卡的攻击力高的攻击力的场上的怪兽不能把效果发动”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c99115354.actlimit)
	c:RegisterEffect(e2)
	-- “这个卡名的②的效果1回合只能使用1次。②：这张卡被对方破坏送去墓地的场合，以自己墓地的种族和属性是相同的1只调整和1只调整以外的怪兽为对象才能发动。那些怪兽加入手卡。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99115354,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,99115354)
	e3:SetCondition(c99115354.thcon)
	e3:SetTarget(c99115354.thtg)
	e3:SetOperation(c99115354.thop)
	c:RegisterEffect(e3)
end
-- 作为①效果的攻击限制判定：若怪兽的攻击力低于这张卡的当前攻击力，则该怪兽不能进行攻击。
function c99115354.atktg(e,c)
	return c:GetAttack()<e:GetHandler():GetAttack()
end
-- 作为①效果中效果发动限制的判定：若发动效果的怪兽位于怪兽区域，且其攻击力高于这张卡的当前攻击力，则该怪兽不能把效果发动。
function c99115354.actlimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetAttack()>e:GetHandler():GetAttack()
end
-- ②效果的发动条件：这张卡被对方玩家破坏并被送去墓地。
function c99115354.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and rp==1-tp
end
-- ②效果选择调整怪兽时的过滤条件：该怪兽是怪兽、是调整、能加入手牌，并且墓地中存在另一只与其种族和属性相同的调整以外怪兽且能加入手牌。
function c99115354.thfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
		-- 确认墓地存在至少1只符合条件的调整以外怪兽，其属性、种族与当前候选调整怪兽相同且能加入手牌，保证两个对象都能选出。
		and Duel.IsExistingTarget(c99115354.thfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetAttribute(),c:GetRace())
end
-- ②效果选择调整以外怪兽时的过滤条件：该怪兽是怪兽、不是调整、属性等于指定属性、种族等于指定种族、并且能加入手牌。
function c99115354.thfilter2(c,att,rac)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER) and c:IsAttribute(att) and c:IsRace(rac) and c:IsAbleToHand()
end
-- ②效果的发动时选择对象：从墓地选择1只调整怪兽和1只与其种族、属性相同的调整以外怪兽作为效果对象，并将这些对象登记为本次效果处理的信息。
function c99115354.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- ②效果的发动条件检查：在效果发动时确认墓地存在至少1只满足条件的调整怪兽（连带确认有对应的调整以外怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c99115354.thfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家显示选择提示信息，内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只符合条件的调整怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c99115354.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 再次向玩家显示选择提示信息，内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只与已选调整怪兽种族和属性相同的调整以外怪兽作为第二个效果对象。
	local g2=Duel.SelectTarget(tp,c99115354.thfilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),g1:GetFirst():GetAttribute(),g1:GetFirst():GetRace())
	g1:Merge(g2)
	-- 将选中的2只怪兽登记为本效果处理时加入手牌的对象，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果处理：将作为对象的两只怪兽加入持有者手牌。
function c99115354.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的2只对象卡片，并筛选出仍与此效果相关的卡片（例如仍在墓地且未被其他效果转移的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的对象卡片加入其持有者的手牌，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
