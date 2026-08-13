--シンクロ・フュージョニスト
-- 效果：
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c15839054.initial_effect(c)
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15839054,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c15839054.condition)
	e1:SetTarget(c15839054.target)
	e1:SetOperation(c15839054.operation)
	c:RegisterEffect(e1)
end
-- 发动条件检查：此卡作为同调素材被送去墓地，且此卡当前在墓地，才能发动。
function c15839054.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检索过滤：从卡组选出含有「融合」字段的魔法卡，且该卡能够加入手卡。
function c15839054.filter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动时的目标设定：先检查卡组是否有符合条件的「融合」魔法卡，再设置本效果执行时将卡组卡片加入手牌的操作信息。
function c15839054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时点检查（chk==0），返回己方卡组是否存在至少1张符合条件的「融合」魔法卡，用于判断效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15839054.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果执行时会将1张卡从卡组加入持有者手牌，用于连锁检测和效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1张符合条件的「融合」魔法卡加入手牌，并向对方展示。
function c15839054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”，引导玩家进行卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中精确选择1张符合条件的「融合」魔法卡，供玩家决定加入手牌的卡。
	local g=Duel.SelectMatchingCard(tp,c15839054.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，处理原因为效果生效。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认，确保信息对称。
		Duel.ConfirmCards(1-tp,g)
	end
end
