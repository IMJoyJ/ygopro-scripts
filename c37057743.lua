--炎星皇－チョウライオ
-- 效果：
-- 炎属性3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只炎属性怪兽为对象才能发动。那只炎属性怪兽加入手卡。这个效果的发动后，直到回合结束时自己不能把作为对象的怪兽以及那些同名怪兽召唤·特殊召唤。
function c37057743.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可以用2只炎属性3星怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只炎属性怪兽为对象才能发动。那只炎属性怪兽加入手卡。这个效果的发动后，直到回合结束时自己不能把作为对象的怪兽以及那些同名怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37057743,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c37057743.thcost)
	e1:SetTarget(c37057743.thtg)
	e1:SetOperation(c37057743.thop)
	c:RegisterEffect(e1)
end
-- 代价判定与执行：检查这张卡是否可移除1个超量素材；发动时实际移除这张卡的1个超量素材作为代价。
function c37057743.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：选择自己墓地中1只炎属性且能够加入手卡的怪兽。
function c37057743.filter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 目标选择处理：检查能否取对象，并提示玩家从自己墓地选择1只符合条件的炎属性怪兽，选定后将其登记为对象并设置加入手卡的操作信息。
function c37057743.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37057743.filter(chkc) end
	-- 发动条件检查：自己墓地中是否存在至少1只符合条件的炎属性怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c37057743.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：弹出“请选择要加入手牌的卡”的选择框供玩家选取卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择：从自己墓地选择1只符合条件的炎属性怪兽，并将其设定为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c37057743.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：宣告本次效果将对象卡加入手卡，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象并将其加入手卡，若成功则给己方添加本回合不能召唤/特殊召唤该对象及其同名卡的限制效果。
function c37057743.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与效果关联且仍是炎属性，且加入手卡成功后才执行后续的自肃限制。
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_FIRE) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 这个效果的发动后，直到回合结束时自己不能把作为对象的怪兽以及那些同名怪兽召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c37057743.sumlimit)
		e1:SetLabel(tc:GetCode())
		-- 将“不能特殊召唤对象及其同名卡”的限制效果注册给己方，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		-- 将“不能召唤对象及其同名卡”的限制效果注册给己方，与不能特殊召唤效果共同完成自肃。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 自肃判定：若卡片卡名与记录的对象卡名相同（即对象及同名卡），则受到不能召唤/特殊召唤的限制。
function c37057743.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
