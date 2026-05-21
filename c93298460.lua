--魔装戦士 ヴァンドラ
-- 效果：
-- ①：这张卡可以直接攻击。
-- ②：这张卡从场上送去墓地的场合，以自己墓地1只龙族·战士族·魔法师族的通常怪兽为对象才能发动。那只怪兽加入手卡。
function c93298460.initial_effect(c)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以自己墓地1只龙族·战士族·魔法师族的通常怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93298460,0))  --"卡片回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c93298460.condition)
	e2:SetTarget(c93298460.target)
	e2:SetOperation(c93298460.operation)
	c:RegisterEffect(e2)
end
-- 判断发动条件：此卡是否从场上送去墓地
function c93298460.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：自己墓地的龙族、战士族或魔法师族的通常怪兽，且能加入手卡
function c93298460.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON+RACE_WARRIOR+RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 效果发动阶段：进行对象合法性检测，选择目标怪兽并设置操作信息
function c93298460.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93298460.filter(chkc) end
	-- 在发动阶段（chk==0）检测自己墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c93298460.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c93298460.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理阶段：获取对象卡片，若其仍符合条件则将其加入手牌
function c93298460.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
