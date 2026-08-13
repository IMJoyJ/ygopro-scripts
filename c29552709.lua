--ダイガスタ・スフィアード
-- 效果：
-- 调整＋调整以外的「薰风」怪兽1只以上
-- ①：这张卡同调召唤成功时，以自己墓地1张「薰风」卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡不会被战斗破坏。
-- ③：只要这张卡在怪兽区域存在，自己的「薰风」怪兽的战斗发生的对自己的战斗伤害由对方代受。
function c29552709.initial_effect(c)
	-- 为卡牌添加同调召唤手续：调整1只（不限制，即任意调整）＋调整以外的「薰风」怪兽1只以上，合计为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- 对应①效果：这张卡同调召唤成功时，以自己墓地1张「薰风」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29552709,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c29552709.condition)
	e1:SetTarget(c29552709.target)
	e1:SetOperation(c29552709.operation)
	c:RegisterEffect(e1)
	-- 对应③效果：只要这张卡在怪兽区域存在，自己的「薰风」怪兽的战斗发生的对自己的战斗伤害由对方代受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetTarget(c29552709.reftg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对应②效果：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- e2效果（战斗伤害转移）适用对象的判断条件：只对「薰风」怪兽生效。
function c29552709.reftg(e,c)
	return c:IsSetCard(0x10)
end
-- e1效果的发动条件：这张卡是以同调召唤方式特殊召唤成功。
function c29552709.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- e1效果选取对象的过滤条件：必须是「薰风」卡，且能够加入手牌。
function c29552709.filter(c)
	return c:IsSetCard(0x10) and c:IsAbleToHand()
end
-- e1取对象效果的发动与处理定义：选择自己墓地1张「薰风」卡为对象，并在处理时将其加入手牌。
function c29552709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29552709.filter(chkc) end
	-- 效果发动时检查自己墓地是否存在至少1张符合条件的「薰风」卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c29552709.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 让玩家从满足条件的卡中选择要加入手牌的卡，并显示对应提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的「薰风」卡中选择1张作为效果对象。
	local g=Duel.SelectTarget(tp,c29552709.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁处理的操作信息，表明该效果涉及把对象卡加入手牌（CATEGORY_TOHAND），并记录目标卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的动作：将所选对象卡加入持有者手牌。
function c29552709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因（REASON_EFFECT）送去（加入）其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
