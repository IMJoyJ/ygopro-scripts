--月光輪廻舞踊
-- 效果：
-- 「月光轮回舞踊」在1回合只能发动1张。
-- ①：自己场上的怪兽被战斗·效果破坏的场合才能发动。从卡组把最多2只「月光」怪兽加入手卡。
function c11193246.initial_effect(c)
	-- 「月光轮回舞踊」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,11193246+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c11193246.condition)
	e1:SetTarget(c11193246.target)
	e1:SetOperation(c11193246.operation)
	c:RegisterEffect(e1)
end
-- 检查被破坏的怪兽是否为战斗或效果破坏且在自己场上
function c11193246.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 效果发动的场合条件，判断是否有满足条件的怪兽被破坏
function c11193246.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11193246.cfilter,1,nil,tp)
end
-- 检索满足条件的「月光」怪兽
function c11193246.thfilter(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动步骤，判断是否可以发动此效果
function c11193246.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c11193246.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，准备将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理步骤，执行效果的处理流程
function c11193246.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组选择1到2张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c11193246.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
