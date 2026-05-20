--WW－グラス・ベル
-- 效果：
-- 「风魔女-玻璃铃」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「风魔女-玻璃铃」以外的1只「风魔女」怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c71007216.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「风魔女-玻璃铃」以外的1只「风魔女」怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71007216,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,71007216)
	e1:SetTarget(c71007216.target)
	e1:SetOperation(c71007216.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中除「风魔女-玻璃铃」以外的「风魔女」怪兽且能加入手牌的卡片
function c71007216.filter(c)
	return c:IsSetCard(0xf0) and c:IsType(TYPE_MONSTER) and not c:IsCode(71007216) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测（检查卡组中是否存在可检索的卡，并设置操作信息为将卡片加入手牌）
function c71007216.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c71007216.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理逻辑（从卡组选择1只「风魔女」怪兽加入手牌，并施加直到回合结束时只能特殊召唤风属性怪兽的限制）
function c71007216.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c71007216.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片通过效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71007216.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该限制效果，使其在回合结束前生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非风属性的怪兽
function c71007216.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
