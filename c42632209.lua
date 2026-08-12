--炎斬機ファイナルシグマ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在额外怪兽区域存在，不受「斩机」卡以外的卡的效果影响。
-- ②：额外怪兽区域的这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」卡加入手卡。
function c42632209.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡只要在额外怪兽区域存在，不受「斩机」卡以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c42632209.imcon)
	e1:SetValue(c42632209.efilter)
	c:RegisterEffect(e1)
	-- ②：额外怪兽区域的这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c42632209.damcon)
	-- 将战斗伤害设置为2倍
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,42632209)
	e3:SetCondition(c42632209.thcon)
	e3:SetTarget(c42632209.thtg)
	e3:SetOperation(c42632209.thop)
	c:RegisterEffect(e3)
end
-- 判断效果是否生效：当此卡在额外怪兽区域时
function c42632209.imcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 判断效果是否生效：当效果来源不是「斩机」卡时
function c42632209.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x132)
end
-- 判断效果是否生效：当此卡有战斗对手且在额外怪兽区域时
function c42632209.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():GetSequence()>4
end
-- 判断效果是否发动：当此卡因战斗或对方效果被破坏时
function c42632209.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 检索过滤函数：满足「斩机」卡且能加入手牌的卡
function c42632209.thfilter(c)
	return c:IsSetCard(0x132) and c:IsAbleToHand()
end
-- 设置连锁操作信息：准备从卡组检索1张「斩机」卡加入手牌
function c42632209.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42632209.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：指定要处理的卡为1张「斩机」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作：选择并加入手牌
function c42632209.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「斩机」卡
	local g=Duel.SelectMatchingCard(tp,c42632209.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
