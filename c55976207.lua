--契約の遂行
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。装备怪兽的等级直到回合结束时变成和给人观看的怪兽的等级相同。
-- ②：装备怪兽被解放让这张卡被送去墓地的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c55976207.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c55976207.target)
	e1:SetOperation(c55976207.operation)
	c:RegisterEffect(e1)
	-- （装备限制）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。装备怪兽的等级直到回合结束时变成和给人观看的怪兽的等级相同。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55976207,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,55976207)
	e3:SetCost(c55976207.lvcost)
	e3:SetOperation(c55976207.lvop)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被解放让这张卡被送去墓地的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55976207,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,55976208)
	e4:SetCondition(c55976207.descon)
	e4:SetTarget(c55976207.destg)
	e4:SetOperation(c55976207.desop)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c55976207.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理（将这张卡装备给目标怪兽）
function c55976207.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备魔法卡发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤手卡中未示出、等级与装备怪兽不同且等级在1以上的仪式怪兽
function c55976207.costfilter(c,lv)
	return not c:IsPublic() and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 效果①的发动代价处理（展示手卡中的仪式怪兽并记录其等级）
function c55976207.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽是否存在且有等级，以及手卡中是否存在满足条件的仪式怪兽
	if chk==0 then return tc and tc:IsLevelAbove(1) and Duel.IsExistingMatchingCard(c55976207.costfilter,tp,LOCATION_HAND,0,1,nil,tc:GetLevel()) end
	-- 提示玩家选择要给对方观看的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c55976207.costfilter,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel())
	-- 将选择的仪式怪兽给对方玩家观看确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切发动效果玩家的手卡
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetFirst():GetLevel())
	tc:CreateEffectRelation(e)
end
-- 效果①的效果处理（将装备怪兽的等级变成与展示怪兽相同）
function c55976207.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 装备怪兽的等级直到回合结束时变成和给人观看的怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 检查是否满足效果②的发动条件（装备怪兽被解放导致这张卡失去装备对象送去墓地）
function c55976207.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetPreviousEquipTarget()
	return tc and tc:IsReason(REASON_RELEASE) and c:IsReason(REASON_LOST_TARGET)
end
-- 效果②的对象选择与效果处理准备
function c55976207.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为破坏对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理（破坏选中的对方怪兽）
function c55976207.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②发动时选择的破坏对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
