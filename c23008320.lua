--コール・リゾネーター
-- 效果：
-- ①：从卡组把1只「共鸣者」怪兽加入手卡。
function c23008320.initial_effect(c)
	-- ①：从卡组把1只「共鸣者」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23008320.target)
	e1:SetOperation(c23008320.activate)
	c:RegisterEffect(e1)
end
-- 此过滤条件判定卡是否满足是「共鸣者」系列怪兽、怪兽卡且能被加入手卡。
function c23008320.filter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：检查卡组是否存在符合条件的「共鸣者」怪兽，若存在则登记本次操作信息（从卡组将1张卡加入手卡）。
function c23008320.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查卡组中是否存在至少1张满足c23008320.filter的「共鸣者」怪兽，用于决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23008320.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的处理信息：该效果属于将1张卡从卡组加入手卡（CATEGORY_TOHAND/CATEGORY_SEARCH），目标玩家为tp，目标区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1只符合条件的「共鸣者」怪兽加入手卡，并将所选卡展示给对手确认。
function c23008320.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中选择1张满足c23008320.filter的「共鸣者」怪兽（数量固定为1）。
	local g=Duel.SelectMatchingCard(tp,c23008320.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的卡以效果原因（REASON_EFFECT）送去其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对手（1-tp）确认，保证检索信息的公开透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
