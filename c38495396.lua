--セイクリッド・トレミスM7
-- 效果：
-- 6星怪兽×2
-- 这张卡也能在「星圣神龙 托勒密星团M7」以外的自己场上的「星圣」超量怪兽上面重叠来超量召唤。这个方法特殊召唤的回合，这张卡的①的效果不能发动。
-- ①：1回合1次，把这张卡1个超量素材取除，以自己或对方的场上·墓地1只怪兽为对象才能发动。那只怪兽回到手卡。
function c38495396.initial_effect(c)
	aux.AddXyzProcedure(c,nil,6,2,c38495396.ovfilter,aux.Stringid(38495396,1),2,c38495396.xyzop)  --"是否在「星圣」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- 创建并注册一个起动效果，用于发动①效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38495396,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c38495396.thcost)
	e2:SetTarget(c38495396.thtg)
	e2:SetOperation(c38495396.thop)
	c:RegisterEffect(e2)
end
-- 判断是否为「星圣」超量怪兽（除自身外）
function c38495396.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and not c:IsCode(38495396) and c:IsType(TYPE_XYZ)
end
-- 在以「星圣」超量怪兽为对象进行超量召唤时，为该怪兽设置标记，表示其在本回合不能发动①效果
function c38495396.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(38495396,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- 支付1个超量素材作为发动①效果的代价
function c38495396.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选可以送回手牌的怪兽（必须是怪兽卡且能送回手牌）
function c38495396.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置①效果的目标选择条件，确保目标为场上或墓地的怪兽
function c38495396.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c38495396.thfilter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(38495396)==0
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c38495396.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要送回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 优先从场上选择满足条件的目标怪兽
	local g=aux.SelectTargetFromFieldFirst(tp,c38495396.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理时的操作信息，表示将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行①效果的处理程序，将目标怪兽送回手牌
function c38495396.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
