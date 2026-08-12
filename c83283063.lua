--戦神－不知火
-- 效果：
-- 不死族调整＋调整以外的不死族怪兽1只以上
-- 自己对「战神-不知火」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合，从自己墓地把1只不死族怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的怪兽的原本攻击力数值。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合，以除外的1只自己的守备力0的不死族怪兽为对象才能发动。那只怪兽回到墓地。
function c83283063.initial_effect(c)
	c:SetSPSummonOnce(83283063)
	-- 添加同调召唤手续：不死族调整＋调整以外的不死族怪兽1只以上
	aux.AddSynchroProcedure(c,c83283063.synfilter,aux.NonTuner(c83283063.synfilter),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，从自己墓地把1只不死族怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83283063,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(c83283063.cost)
	e1:SetOperation(c83283063.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合，以除外的1只自己的守备力0的不死族怪兽为对象才能发动。那只怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83283063,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c83283063.tgcon)
	e2:SetTarget(c83283063.tgtg)
	e2:SetOperation(c83283063.tgop)
	c:RegisterEffect(e2)
end
-- 过滤同调素材：不死族怪兽
function c83283063.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 过滤自己墓地中可以作为代价除外且原本攻击力大于0的不死族怪兽
function c83283063.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:GetBaseAttack()>0 and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价：从自己墓地将1只不死族怪兽除外，并记录其原本攻击力
function c83283063.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足除外条件的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83283063.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地中1只满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c83283063.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetBaseAttack())
end
-- 效果①的效果处理：使这张卡的攻击力上升除外怪兽的原本攻击力数值，直到回合结束
function c83283063.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升除外的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检查发动条件：场上的这张卡被战斗或效果破坏并送去墓地
function c83283063.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤除外状态的、守备力为0的不死族怪兽
function c83283063.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsDefense(0)
end
-- 效果②的靶向选择与效果声明：选择除外的1只自己的守备力0的不死族怪兽为对象
function c83283063.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c83283063.filter(chkc) end
	-- 检查除外区是否存在可以作为对象的、守备力为0的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c83283063.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择除外的1只自己的守备力0的不死族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83283063.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的效果处理：使作为对象的除外怪兽回到墓地
function c83283063.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽送回墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
