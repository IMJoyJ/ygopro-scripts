--ライトロード・ウォリアー ガロス
-- 效果：
-- 「光道战士 加洛斯」以外的自己场上的名字带有「光道」的怪兽的效果从自己卡组让卡送去墓地的场合，从自己卡组上面把2张卡送去墓地。那之后，从卡组抽出这个效果送去墓地的名字带有「光道」的怪兽数量的卡。
function c59019082.initial_effect(c)
	-- 「光道战士 加洛斯」以外的自己场上的名字带有「光道」的怪兽的效果从自己卡组让卡送去墓地的场合，从自己卡组上面把2张卡送去墓地。那之后，从卡组抽出这个效果送去墓地的名字带有「光道」的怪兽数量的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(59019082,0))  --"从卡组送2张卡去墓地"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c59019082.condtion)
	e1:SetTarget(c59019082.target)
	e1:SetOperation(c59019082.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否是从卡组送去墓地
function c59019082.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 触发条件：自己场上「光道战士 加洛斯」以外的「光道」怪兽在怪兽区域发动效果，且该效果将卡组的卡送去墓地
function c59019082.condtion(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rp==tp and bit.band(r,REASON_EFFECT)~=0 and not rc:IsCode(59019082) and rc:IsSetCard(0x38) and rc:IsType(TYPE_MONSTER)
		and re:GetActivateLocation()==LOCATION_MZONE and eg:IsExists(c59019082.cfilter,1,nil)
end
-- 效果发动时的目标处理：此效果为必发效果，直接返回true，并设置从卡组送去墓地的操作信息
function c59019082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从自己卡组上面把2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 过滤条件：检查卡片是否在墓地、是否是名字带有「光道」的怪兽
function c59019082.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 效果处理：从卡组上面把2张卡送去墓地，之后抽出其中「光道」怪兽数量的卡
function c59019082.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组上面把2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	-- 获取刚才因效果送去墓地的卡片组
	local dg=Duel.GetOperatedGroup()
	local d=dg:FilterCount(c59019082.filter,nil)
	if d>0 then
		-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
		Duel.BreakEffect()
		-- 从卡组抽出这个效果送去墓地的名字带有「光道」的怪兽数量的卡
		Duel.Draw(tp,d,REASON_EFFECT)
	end
end
