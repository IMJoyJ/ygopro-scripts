--EMセカンドンキー
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把「娱乐伙伴 副手驴」以外的1只「娱乐伙伴」怪兽送去墓地。自己的灵摆区域有2张卡存在的场合，也能不送去墓地加入手卡。
function c15978426.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15978426,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c15978426.tgtg)
	e1:SetOperation(c15978426.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「娱乐伙伴」怪兽
function c15978426.filter(c,tohand)
	return c:IsSetCard(0x9f) and not c:IsCode(15978426) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToGrave() or (tohand and c:IsAbleToHand()))
end
-- 效果发动时的处理函数，检查是否满足发动条件并设置操作信息
function c15978426.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断玩家灵摆区域是否有两张卡
		local tohand=Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		-- 检查卡组中是否存在满足条件的怪兽
		return Duel.IsExistingMatchingCard(c15978426.filter,tp,LOCATION_DECK,0,1,nil,tohand)
	end
	-- 设置连锁操作信息，指定将要处理的卡为卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，根据条件选择将怪兽送去墓地或加入手卡
function c15978426.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家灵摆区域是否有两张卡
	local tohand=Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c15978426.filter,tp,LOCATION_DECK,0,1,1,nil,tohand)
	local tc=g:GetFirst()
	if not tc then return end
	-- 判断是否可以将怪兽加入手卡并进行选择
	if tohand and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1190)==1) then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
