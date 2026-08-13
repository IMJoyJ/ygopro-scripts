--魔道化リジョン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只魔法师族怪兽表侧攻击表示上级召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地选1只魔法师族通常怪兽加入手卡。
function c25280974.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只魔法师族怪兽表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25280974,1))  --"使用「魔道化 利真」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	-- 设置该额外召唤次数的适用对象：只有魔法师族怪兽可以享受这1次额外的通常召唤。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e1:SetValue(0x1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地选1只魔法师族通常怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25280974,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,25280974)
	e2:SetCondition(c25280974.thcon)
	e2:SetTarget(c25280974.thtg)
	e2:SetOperation(c25280974.thop)
	c:RegisterEffect(e2)
end
-- 发动条件：这张卡原位置在场上区域，即从场上送去墓地时才能发动。
function c25280974.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤条件：选择的对象必须是魔法师族通常怪兽，并且可以被加入手卡。
function c25280974.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 发动时目标检查：确认卡组或墓地是否存在符合条件的魔法师族通常怪兽，并设置效果处理时要加入手卡的操作信息。
function c25280974.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：己方卡组或墓地中是否存在至少1张符合条件的魔法师族通常怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25280974.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：声明本效果将处理“加入手卡”分类，目标数为1，检索区域为卡组和墓地，供相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：玩家选择1张符合条件的魔法师族通常怪兽加入手卡，并向对方展示。
function c25280974.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组·墓地选择1张符合条件的魔法师族通常怪兽（过滤掉受王家长眠之谷影响不能移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25280974.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
