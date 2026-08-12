--捕食植物ダーリング・コブラ
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡用「捕食植物」怪兽的效果特殊召唤的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c61677004.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡用「捕食植物」怪兽的效果特殊召唤的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61677004,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,61677004+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c61677004.thcon)
	e1:SetTarget(c61677004.thtg)
	e1:SetOperation(c61677004.thop)
	c:RegisterEffect(e1)
end
-- 发动条件：判断这张卡是否是由「捕食植物」怪兽的效果特殊召唤成功
function c61677004.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x10f3)
end
-- 过滤条件：卡组中属于「融合」字段的魔法卡，且可以加入手牌
function c61677004.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动阶段：检查卡组中是否存在可检索的「融合」魔法卡，并设置将卡片加入手牌的操作信息
function c61677004.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点，检查卡组中是否存在至少1张满足过滤条件的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c61677004.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组选择1张「融合」魔法卡加入手牌并给对方确认
function c61677004.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在界面上提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,c61677004.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
