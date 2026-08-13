--剣闘訓練所
-- 效果：
-- 从自己卡组把1只4星以下的名字带有「剑斗兽」的怪兽加入手卡。
function c35224440.initial_effect(c)
	-- 从自己卡组把1只4星以下的名字带有「剑斗兽」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35224440.target)
	e1:SetOperation(c35224440.activate)
	c:RegisterEffect(e1)
end
-- 定义检索过滤条件：该卡必须是名字带有「剑斗兽」、等级4以下且能够被加入手卡的怪兽。
function c35224440.filter(c)
	return c:IsSetCard(0x1019) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 发动时的目标处理：在发动时确认卡组存在符合条件的怪兽，并设置效果处理时从卡组将1只怪兽加入手卡的操作信息。
function c35224440.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：仅在己方卡组中存在至少1只满足条件的「剑斗兽」怪兽时才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35224440.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果处理时将把1张卡从卡组加入手卡（CATEGORY_TOHAND），供相关连锁和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：从卡组选择1只符合条件的「剑斗兽」怪兽加入手卡，并向对方玩家确认。
function c35224440.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由发动玩家从自己的卡组中选择1张满足检索条件的「剑斗兽」怪兽（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c35224440.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（此处为发动者手卡），操作原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手卡的怪兽展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
