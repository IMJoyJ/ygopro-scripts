--ヴァイロン・キューブ
-- 效果：
-- 这张卡被光属性怪兽的同调召唤使用送去墓地的场合，可以从自己卡组选择1张装备魔法卡加入手卡。
function c41431329.initial_effect(c)
	-- 创建效果，设置效果描述为检索，分类为回手牌和检索，类型为单体诱发选发效果，触发事件为作为同调素材，条件为thcon，目标为thtg，效果处理为thop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41431329,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c41431329.thcon)
	e1:SetTarget(c41431329.thtg)
	e1:SetOperation(c41431329.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在墓地，且是因为同调召唤被送入墓地，且送入墓地的怪兽具有光属性
function c41431329.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and c:GetReasonCard():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤函数，用于筛选可以加入手牌的装备魔法卡
function c41431329.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 设置效果处理时的目标，检查自己卡组是否存在至少1张装备魔法卡
function c41431329.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41431329.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示选择装备魔法卡并将其加入手牌，同时确认对方查看该卡
function c41431329.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c41431329.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的装备魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
