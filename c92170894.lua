--EMロングフォーン・ブル
-- 效果：
-- 「娱乐伙伴 电话长角牛」的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把灵摆怪兽以外的1只「娱乐伙伴」怪兽加入手卡。
function c92170894.initial_effect(c)
	-- 「娱乐伙伴 电话长角牛」的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。从卡组把灵摆怪兽以外的1只「娱乐伙伴」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92170894,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92170894)
	e1:SetTarget(c92170894.thtg)
	e1:SetOperation(c92170894.tgop)
	c:RegisterEffect(e1)
end
-- 过滤卡组中属于「娱乐伙伴」且非灵摆怪兽的怪兽卡
function c92170894.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果发动目标：检查卡组中是否存在符合条件的卡，并设置将卡加入手卡的操作信息
function c92170894.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c92170894.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的卡加入手卡，并给对方确认
function c92170894.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c92170894.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
