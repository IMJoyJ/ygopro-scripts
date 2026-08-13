--九蛇孔雀
-- 效果：
-- 场上的这张卡被解放送去墓地的场合，可以从自己的卡组·墓地选「九蛇孔雀」以外的1只4星以下的风属性怪兽加入手卡。「九蛇孔雀」的效果1回合只能使用1次。
function c24384095.initial_effect(c)
	-- 对应效果原文：场上的这张卡被解放送去墓地的场合，可以从自己的卡组·墓地选「九蛇孔雀」以外的1只4星以下的风属性怪兽加入手卡。「九蛇孔雀」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24384095,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,24384095)
	e1:SetCondition(c24384095.thcon)
	e1:SetTarget(c24384095.thtg)
	e1:SetOperation(c24384095.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定这张卡此前位于场上，且本次离场原因为解放，即满足“场上的这张卡被解放送去墓地”的触发条件。
function c24384095.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_RELEASE)
end
-- 检索目标的筛选条件：选择等级4以下、风属性、卡名不是「九蛇孔雀」且能够加入手卡的怪兽。
function c24384095.filter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND) and not c:IsCode(24384095) and c:IsAbleToHand()
end
-- 效果发动时的目标选择阶段：先检查自己的卡组和墓地是否存在满足条件的检索目标，若存在则设置本次操作的类型为“加入手卡”并登记可能涉及的区域为卡组和墓地。
function c24384095.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己的卡组·墓地中至少有1只满足检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24384095.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：声明本效果处理时会将1张卡从卡组·墓地加入持有者手牌，用于连锁判定等系统检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理阶段：提示玩家选择，从自己卡组·墓地中选出符合条件的1只风属性怪兽（已过滤王家长眠之谷的影响），将其加入手牌，并向对手展示该卡。
function c24384095.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示信息，通知玩家从符合条件的卡中选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 实际执行检索选择：让玩家tp从自己卡组·墓地中选择1张满足条件且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24384095.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
