--炎斬機ファイナルシグマ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在额外怪兽区域存在，不受「斩机」卡以外的卡的效果影响。
-- ②：额外怪兽区域的这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」卡加入手卡。
function c42632209.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以1只调整（无额外要求）＋调整以外的怪兽1只以上为素材进行同调召唤。
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
	-- 设置②效果的伤害变更值：此卡在与对方怪兽战斗时，给对方造成的战斗伤害变为2倍（DOUBLE_DAMAGE）。
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」卡加入手卡。
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
-- ①效果的适用条件：这张卡位于额外怪兽区域（场上序列号>4，即额外怪兽区）时，其免疫效果才适用。
function c42632209.imcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 免疫过滤函数：若发动效果的那张卡不属于「斩机」字段，则此卡不受该效果影响；「斩机」卡的效果仍可正常影响此卡。
function c42632209.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x132)
end
-- ②效果的适用条件：这张卡正处于与对方怪兽的战斗中（存在战斗对象），且位于额外怪兽区域时，战斗伤害翻倍效果才适用。
function c42632209.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():GetSequence()>4
end
-- ③效果的发动条件：这张卡被战斗破坏，或者被对方玩家的效果破坏（且破坏前控制者为发动方自己）的场合才能发动。
function c42632209.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 检索卡片的过滤条件：选择卡组中1张「斩机」字段且能够加入手卡的卡。
function c42632209.thfilter(c)
	return c:IsSetCard(0x132) and c:IsAbleToHand()
end
-- ③效果发动时的条件检查与操作信息设置：在发动时若卡组中存在符合条件的「斩机」卡则允许发动，并登记本效果为从卡组将1张卡加入手卡的处理信息。
function c42632209.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：仅当卡组中存在至少1张满足thfilter条件的「斩机」卡时，③效果才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c42632209.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：将1张卡从持有者的卡组加入手卡（CATEGORY_TOHAND），同时标记为检索效果（CATEGORY_SEARCH），供相关连锁/检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组中选择1张「斩机」卡加入手卡，并向对方玩家展示确认。
function c42632209.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选出1张满足条件的「斩机」卡（若无符合条件的卡，g为空组）。
	local g=Duel.SelectMatchingCard(tp,c42632209.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
