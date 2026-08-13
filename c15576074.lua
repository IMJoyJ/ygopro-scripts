--リゾネーター・エンジン
-- 效果：
-- ①：以自己墓地2只「共鸣者」怪兽为对象才能发动。从卡组把1只4星怪兽加入手卡，作为对象的怪兽回到卡组。
function c15576074.initial_effect(c)
	-- ①：以自己墓地2只「共鸣者」怪兽为对象才能发动。从卡组把1只4星怪兽加入手卡，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15576074.target)
	e1:SetOperation(c15576074.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的卡：自己墓地的「共鸣者」怪兽且能够返回卡组。
function c15576074.filter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 筛选卡组中满足检索条件的卡：等级4的怪兽且能够加入手卡。
function c15576074.filter2(c)
	return c:IsLevel(4) and c:IsAbleToHand()
end
-- 目标处理与发动条件检查：校验指定对象是否为自己墓地的「共鸣者」且可回卡组，并确认卡组存在1只等级4可加入手卡的怪兽且墓地存在2只可回卡组的「共鸣者」怪兽。
function c15576074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15576074.filter(chkc) end
	-- 发动条件判断：确认卡组中存在至少1只等级4且能加入手卡的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15576074.filter2,tp,LOCATION_DECK,0,1,nil)
		-- 且确认自己墓地存在至少2只可作为对象的「共鸣者」怪兽（能返回卡组）。
		and Duel.IsExistingTarget(c15576074.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给操作玩家显示“请选择要返回卡组的卡”的提示信息，用于选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择2只「共鸣者」怪兽作为效果对象，并将它们设置为连锁对象。
	local g=Duel.SelectTarget(tp,c15576074.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：将选中的对象卡返回卡组（CATEGORY_TODECK），数量为选择的对象数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：从卡组检索1张卡加入手卡（CATEGORY_TOHAND），检索目标在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只等级4怪兽加入手卡并展示给对手，再将之前取为对象且仍与效果关联的「共鸣者」怪兽返回卡组顶端。
function c15576074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作玩家显示“请选择要加入手牌的卡”的提示信息，以便选择检索的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只等级4且能加入手卡的怪兽。
	local g=Duel.SelectMatchingCard(tp,c15576074.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 取回发动时选择的墓地对象，并筛选出仍与本次效果关联的卡（排除已离场等失去联系的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 将这些仍关联的对象卡以效果原因返回持有者卡组顶端。
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
