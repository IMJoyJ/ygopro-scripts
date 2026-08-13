--月光輪廻舞踊
-- 效果：
-- 「月光轮回舞踊」在1回合只能发动1张。
-- ①：自己场上的怪兽被战斗·效果破坏的场合才能发动。从卡组把最多2只「月光」怪兽加入手卡。
function c11193246.initial_effect(c)
	-- 「月光轮回舞踊」在1回合只能发动1张。①：自己场上的怪兽被战斗·效果破坏的场合才能发动。从卡组把最多2只「月光」怪兽加入手卡。
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
-- 筛选被破坏的怪兽：必须是被战斗或效果破坏、且此前在自己主要怪兽区、且此前控制者为自己的怪兽。
function c11193246.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 满足发动条件：本次被破坏的怪兽中存在至少1只符合上述筛选条件的自己场上的怪兽。
function c11193246.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11193246.cfilter,1,nil,tp)
end
-- 检索卡牌的筛选条件：必须是「月光」怪兽且能够加入手卡。
function c11193246.thfilter(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的目标处理：先检查卡组是否存在至少1只符合条件的「月光」怪兽，并登记本次操作信息为从卡组将卡加入手卡。
function c11193246.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认卡组中是否存在至少1只可加入手卡的「月光」怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11193246.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本连锁处理中包含把卡组中的卡加入手卡的效果，计数按最少1张设定，供其他卡进行连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组挑选最多2只「月光」怪兽加入手卡，并向对方确认加入手卡的卡。
function c11193246.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家显示选择提示文字“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1到2只满足条件的「月光」怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c11193246.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认本次加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
