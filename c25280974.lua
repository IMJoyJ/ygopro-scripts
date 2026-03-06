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
	-- 设置效果目标为魔法师族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e1:SetValue(0x1)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地选1只魔法师族通常怪兽加入手卡。
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
-- 效果发动条件：卡片从场上离开
function c25280974.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：选择魔法师族通常怪兽
function c25280974.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 设置效果目标：从卡组或墓地选择1只魔法师族通常怪兽加入手牌
function c25280974.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：卡组或墓地存在1只魔法师族通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25280974.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：选择并加入手牌
function c25280974.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25280974.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
