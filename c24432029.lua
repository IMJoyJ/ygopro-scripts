--ジェネクス・ブラスト
-- 效果：
-- ①：这张卡特殊召唤时才能发动。从卡组把1只暗属性「次世代」怪兽加入手卡。
function c24432029.initial_effect(c)
	-- ①：这张卡特殊召唤时才能发动。从卡组把1只暗属性「次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24432029,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c24432029.target)
	e1:SetOperation(c24432029.operation)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：卡组中的暗属性且具有「次世代」字段、并能被加入手卡的怪兽。
function c24432029.filter(c)
	return c:IsSetCard(0x2) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：先进行可发动检查，再登记从卡组检索加入手卡的操作信息。
function c24432029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组中是否存在至少1张满足筛选条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24432029.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：将该效果登记为玩家tp从卡组将1张卡加入手牌的检索效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家选择符合条件的卡，从卡组选1张加入手牌，并向对方确认。
function c24432029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示文字，供选择卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选出1张满足条件的卡（暗属性「次世代」怪兽且可加入手牌）。
	local g=Duel.SelectMatchingCard(tp,c24432029.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
