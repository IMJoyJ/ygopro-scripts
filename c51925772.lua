--ドレッド・ドラゴン
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只3星以下的龙族怪兽加入手卡。
function c51925772.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只3星以下的龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51925772,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c51925772.condition)
	e1:SetTarget(c51925772.target)
	e1:SetOperation(c51925772.operation)
	c:RegisterEffect(e1)
end
-- 判定效果能否发动：本卡当前位于墓地，且是被战斗破坏（REASON_BATTLE）送去墓地的。
function c51925772.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义从卡组检索的目标条件：等级3以下的龙族怪兽，且可以被加入手卡。
function c51925772.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果发动时的目标设定：确认卡组中存在符合条件的龙族怪兽，若满足则登记本次效果为从卡组将1张卡加入手卡。
function c51925772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性判定（chk==0）时，检查卡组中是否存在至少1张满足条件的龙族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c51925772.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：将本效果处理时从卡组把1张卡加入手卡（CATEGORY_TOHAND）的信息写入连锁，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：从卡组选择1只符合条件的龙族怪兽加入手卡，并展示给对手确认。
function c51925772.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示当前玩家从卡组选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从卡组中选出1张符合条件的龙族怪兽（通过filter过滤），结果存入g。
	local g=Duel.SelectMatchingCard(tp,c51925772.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，移动原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示检索到的卡，完成确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
