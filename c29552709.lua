--ダイガスタ・スフィアード
-- 效果：
-- 调整＋调整以外的「薰风」怪兽1只以上
-- ①：这张卡同调召唤成功时，以自己墓地1张「薰风」卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡不会被战斗破坏。
-- ③：只要这张卡在怪兽区域存在，自己的「薰风」怪兽的战斗发生的对自己的战斗伤害由对方代受。
function c29552709.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的「薰风」怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以自己墓地1张「薰风」卡为对象才能发动。那张卡加入手卡。
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
	-- ③：只要这张卡在怪兽区域存在，自己的「薰风」怪兽的战斗发生的对自己的战斗伤害由对方代受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetTarget(c29552709.reftg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 设置效果目标为自己的「薰风」怪兽
function c29552709.reftg(e,c)
	return c:IsSetCard(0x10)
end
-- 判断是否为同调召唤成功
function c29552709.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的「薰风」怪兽
function c29552709.filter(c)
	return c:IsSetCard(0x10) and c:IsAbleToHand()
end
-- 设置效果目标为墓地的「薰风」怪兽
function c29552709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29552709.filter(chkc) end
	-- 判断是否存在满足条件的墓地「薰风」怪兽
	if chk==0 then return Duel.IsExistingTarget(c29552709.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「薰风」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c29552709.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息为将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果操作，将选中的卡送入手牌
function c29552709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
