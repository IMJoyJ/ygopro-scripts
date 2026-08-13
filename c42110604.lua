--HSRチャンバライダー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「高速疾行机人 比剑骑手」1回合只能有1次特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡进行战斗的伤害步骤开始时发动。这张卡的攻击力上升200。
-- ③：这张卡被送去墓地的场合，以除外的1张自己的「疾行机人」卡为对象才能发动。那张卡加入手卡。
function c42110604.initial_effect(c)
	c:SetSPSummonOnce(42110604)
	-- 为这张卡添加同调召唤手续：同调素材为1只调整怪兽＋1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害步骤开始时发动。这张卡的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42110604,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c42110604.condition)
	e2:SetOperation(c42110604.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以除外的1张自己的「疾行机人」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42110604,1))  --"加入手牌"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c42110604.thtg)
	e3:SetOperation(c42110604.thop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件：判定这张卡是否与本次战斗关联，即这张卡正在进行战斗。
function c42110604.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle()
end
-- ②效果处理：若这张卡仍表侧表示且与效果关联，则使这张卡的攻击力上升200（该增益在卡片离场或被无效等场合重置）。
function c42110604.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③效果的选卡过滤器：选择除外区的1张自己表侧表示的「疾行机人」卡，且该卡能够加入手卡。
function c42110604.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2016) and c:IsAbleToHand()
end
-- ③效果的发动目标选择：取对象为除外区的1张自己表侧表示的「疾行机人」卡；发动时选择该卡，并设置操作信息为回手牌。
function c42110604.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c42110604.thfilter(chkc) end
	-- 发动条件检查：确认自己除外区是否存在至少1张满足「疾行机人」且可加入手卡的表侧表示卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(c42110604.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给发动玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外区的符合条件的卡中选择1张作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c42110604.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：效果处理时将把选择的卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：将效果对象卡加入手牌（若该卡仍与效果关联）。
function c42110604.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡加入其持有者的手卡（即回手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
