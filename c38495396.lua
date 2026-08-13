--セイクリッド・トレミスM7
-- 效果：
-- 6星怪兽×2
-- 这张卡也能在「星圣神龙 托勒密星团M7」以外的自己场上的「星圣」超量怪兽上面重叠来超量召唤。这个方法特殊召唤的回合，这张卡的①的效果不能发动。
-- ①：1回合1次，把这张卡1个超量素材取除，以自己或对方的场上·墓地1只怪兽为对象才能发动。那只怪兽回到手卡。
function c38495396.initial_effect(c)
	aux.AddXyzProcedure(c,nil,6,2,c38495396.ovfilter,aux.Stringid(38495396,1),2,c38495396.xyzop)  --"是否在「星圣」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己或对方的场上·墓地1只怪兽为对象才能发动。那只怪兽回到手卡。
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
-- 超量召唤叠放条件的过滤函数：判断候选怪兽是否为表侧表示、属于“星圣”系列的超量怪兽，且不是这张卡自身（M7），满足此条件才能在该怪兽上重叠进行超量召唤。
function c38495396.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and not c:IsCode(38495396) and c:IsType(TYPE_XYZ)
end
-- 特殊超量召唤成功时执行的操作：给这张卡注册一个直到结束阶段有效的标识，用于记录“这个回合不能发动①效果”。
function c38495396.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(38495396,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- 发动①效果的代价：检查并取除这张卡的1个超量素材（作为COST）。
function c38495396.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 回手牌效果的目标过滤条件：选择怪兽卡，且该怪兽可以被返回手牌。
function c38495396.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的目标判定：若检查已选对象，则验证其位于场上/墓地且满足过滤条件；未指定对象时，则确认本回合没有①效果的禁止标记，且场上/墓地至少存在1只符合条件的怪兽。
function c38495396.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c38495396.thfilter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(38495396)==0
		-- 检查双方场上·墓地是否存在至少1只符合条件的怪兽可作为效果对象。
		and Duel.IsExistingTarget(c38495396.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 向操作玩家显示选择提示，要求选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 优先从场上选择符合条件的怪兽，若场上不足1只则从墓地选择，最终选1只怪兽作为效果对象并登记。
	local g=aux.SelectTargetFromFieldFirst(tp,c38495396.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，宣告本次效果将把1张对象卡返回手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若对象仍与效果关联，则将其返回持有者手牌。
function c38495396.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的第一张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者的手卡，返回原因标记为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
