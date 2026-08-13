--星因士 ウヌク
-- 效果：
-- 「星因士 天市右垣七」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把「星因士 天市右垣七」以外的1张「星骑士」卡送去墓地。
function c1050186.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把「星因士 天市右垣七」以外的1张「星骑士」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1050186,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1050186)
	e1:SetTarget(c1050186.target)
	e1:SetOperation(c1050186.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c1050186.star_knight_summon_effect=e1
end
-- 筛选卡组中满足条件的卡：卡名属于「星骑士」字段、不是「星因士 天市右垣七」、且可以送去墓地。
function c1050186.filter(c)
	return c:IsSetCard(0x9c) and not c:IsCode(1050186) and c:IsAbleToGrave()
end
-- 效果发动时的目标处理：检查卡组是否存在符合条件的「星骑士」卡，并登记本次效果将执行送去墓地的操作信息。
function c1050186.target(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 发动条件判定：从卡组中确认是否存在至少1张满足筛选条件的「星骑士」卡（即非本卡名且能送去墓地的卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c1050186.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 登记效果处理信息：将本连锁效果分类设为送去墓地，预计从持有者卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：提示玩家选择1张符合条件的「星骑士」卡，然后将其从卡组送去墓地。
function c1050186.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组中选出1张满足筛选条件的「星骑士」卡（不包含本卡名且能够送去墓地）。
	local g=Duel.SelectMatchingCard(tp,c1050186.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
