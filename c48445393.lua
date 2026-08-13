--スクラップ・スコール
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽发动。从自己卡组把1只名字带有「废铁」的怪兽送去墓地，抽1张卡。那之后，选择的怪兽破坏。
function c48445393.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽发动。从自己卡组把1只名字带有「废铁」的怪兽送去墓地，抽1张卡。那之后，选择的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48445393.target)
	e1:SetOperation(c48445393.activate)
	c:RegisterEffect(e1)
end
-- 定义破坏对象的筛选函数：要求怪兽为表侧表示且卡名带有「废铁」，用于选择自己场上的废铁怪兽作为破坏对象。
function c48445393.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 定义送去墓地的筛选函数：要求卡组中的怪兽卡名带有「废铁」、是怪兽且可以被送去墓地，用于选择从卡组送墓的废铁怪兽。
function c48445393.sfilter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 发动时的合法性与对象选择处理：检查场上是否有表侧废铁怪兽可取对象、卡组是否有可送墓的废铁怪兽、自己是否还能抽卡；满足后选择破坏对象，并登记破坏、送墓、抽卡的操作信息。
function c48445393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48445393.desfilter(chkc) end
	-- 合法性检查第一步：确认自己场上存在至少1只表侧表示且名字带有「废铁」的怪兽，可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c48445393.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 合法性检查第二步：确认自己卡组存在至少1只名字带有「废铁」且满足送墓条件的怪兽。
		and Duel.IsExistingMatchingCard(c48445393.sfilter,tp,LOCATION_DECK,0,1,nil)
		-- 合法性检查第三步：确认自己玩家可以抽卡（此处代码传入2，作为抽卡效果的发动条件判定）。
		and Duel.IsPlayerCanDraw(tp,2) end
	-- 在发动时向玩家显示“请选择要破坏的卡”的选择提示，用于选择场上的废铁怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只表侧表示的名字带有「废铁」的怪兽，并将其登记为这张效果的对象。
	local g=Duel.SelectTarget(tp,c48445393.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：本次效果将破坏已选择的1只怪兽（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本次效果将从卡组把1只名字带有「废铁」的怪兽送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 登记操作信息：本次效果将使玩家自己抽1张卡（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从卡组选择1只废铁怪兽送去墓地；若成功送墓，则中断效果后抽1张卡，再检查并破坏发动时选择的对象。
function c48445393.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1只名字带有「废铁」且可以送去墓地的怪兽，用于将其送入墓地。
	local g=Duel.SelectMatchingCard(tp,c48445393.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的废铁怪兽以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		if not g:GetFirst():IsLocation(LOCATION_GRAVE) then return end
		-- 中断当前效果处理，使后续的抽卡处理与前面的送墓处理不同时进行（错开时点）。
		Duel.BreakEffect()
		-- 以效果原因让自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 取出发动时选择的那只废铁怪兽，作为后续破坏处理的对象。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 再次中断效果处理，使破坏处理与抽卡处理不同时进行（错开时点）。
			Duel.BreakEffect()
			-- 如果之前选择的对象仍然与效果相关且保持表侧表示，则将其破坏（效果破坏）。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
