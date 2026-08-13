--EMセカンドンキー
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把「娱乐伙伴 副手驴」以外的1只「娱乐伙伴」怪兽送去墓地。自己的灵摆区域有2张卡存在的场合，也能不送去墓地加入手卡。
function c15978426.initial_effect(c)
	-- 对应效果原文：①：这张卡召唤·特殊召唤成功时才能发动。从卡组把「娱乐伙伴 副手驴」以外的1只「娱乐伙伴」怪兽送去墓地。自己的灵摆区域有2张卡存在的场合，也能不送去墓地加入手卡。
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
-- 筛选卡组中满足条件的卡：必须是「娱乐伙伴」怪兽、不是「娱乐伙伴 副手驴」、是怪兽卡，并且能够被送去墓地；若我方灵摆区域有2张卡（tohand为真），也可选择能够加入手卡的卡。
function c15978426.filter(c,tohand)
	return c:IsSetCard(0x9f) and not c:IsCode(15978426) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToGrave() or (tohand and c:IsAbleToHand()))
end
-- 发动时进行条件判定：先检查我方灵摆区域是否有2张卡（作为能否加入手卡的追加条件），再检查卡组中是否存在至少1张符合条件的「娱乐伙伴」怪兽；若可以发动，登记效果处理时将把卡组1张卡送去墓地的操作信息。
function c15978426.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 确认我方灵摆区域是否同时存在第0区和第1区的卡；若两张灵摆卡都在，则返回第1区的卡作为真值，用于表示可以选择“加入手卡”的路线，否则返回nil。
		local tohand=Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		-- 检查我方卡组是否存在至少1张满足c15978426.filter条件的卡（至少1张，排除ex=nil），以此作为效果能否发动的条件。
		return Duel.IsExistingMatchingCard(c15978426.filter,tp,LOCATION_DECK,0,1,nil,tohand)
	end
	-- 登记效果的操作信息：本效果处理时将把卡组中的1张卡送去墓地，用于连锁判定和效果发动后的信息记录。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：再次确认灵摆区域有2张卡，选择卡组中1张符合条件的「娱乐伙伴」怪兽；若满足灵摆区2张且该卡能加入手卡，则让玩家选择送去墓地或加入手卡（不能送墓时自动加入手卡），并执行对应的送墓或加入手卡、展示给对手。
function c15978426.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认我方灵摆区域是否同时存在第0区和第1区的卡；若两张灵摆卡都在，则返回第1区的卡作为真值，用于表示可以选择“加入手卡”的路线，否则返回nil。
	local tohand=Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	-- 向操作的玩家显示“请选择要送去墓地的卡”的提示文字（HINTMSG_TOGRAVE），作为选择卡组的引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选出1张满足c15978426.filter条件的「娱乐伙伴」怪兽（并传入tohand，使筛选时知道能否选择加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c15978426.filter,tp,LOCATION_DECK,0,1,1,nil,tohand)
	local tc=g:GetFirst()
	if not tc then return end
	-- 判断是否加入手卡：只有灵摆区有2张卡、选择的卡能够加入手卡，并且（该卡不能送去墓地，或玩家在“送去墓地/加入手卡”选项中选择了加入手卡）时，才执行加入手卡；否则执行送墓。
	if tohand and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1190)==1) then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认这张加入手卡的卡，公开检索/加入手卡的卡牌信息。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
