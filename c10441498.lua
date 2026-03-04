--輝神鳥ヴェーヌ
-- 效果：
-- 「原初的叫唤」降临。
-- ①：1回合1次，把手卡1只怪兽给对方观看，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽的等级变成和给人观看的怪兽相同。
-- ②：1回合1次，这张卡以外的自己的手卡·场上的怪兽被解放的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
function c10441498.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：1回合1次，把手卡1只怪兽给对方观看，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽的等级变成和给人观看的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10441498,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c10441498.lvtg)
	e1:SetOperation(c10441498.lvop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡以外的自己的手卡·场上的怪兽被解放的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10441498,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetCondition(c10441498.thcon)
	e2:SetTarget(c10441498.thtg)
	e2:SetOperation(c10441498.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的怪兽（等级大于等于1且未公开），并且场上有满足条件的怪兽作为效果对象。
function c10441498.cfilter(c,tp)
	-- 返回值为true表示手卡中存在满足条件的怪兽（等级大于等于1且未公开），并且场上有满足条件的怪兽作为效果对象。
	return c:IsLevelAbove(1) and not c:IsPublic() and Duel.IsExistingTarget(c10441498.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（表侧表示且等级大于等于1），并且等级与给定等级不同。
function c10441498.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 效果处理函数，用于设置效果的目标选择逻辑。
function c10441498.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10441498.lvfilter(chkc,e:GetLabel()) end
	-- 检查是否满足发动条件，即手卡中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c10441498.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 从手卡中选择一张满足条件的怪兽。
	local cg=Duel.SelectMatchingCard(tp,c10441498.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将所选怪兽展示给对方玩家。
	Duel.ConfirmCards(1-tp,cg)
	-- 将玩家手卡洗牌。
	Duel.ShuffleHand(tp)
	local lv=cg:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择场上满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c10441498.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lv)
end
-- 效果处理函数，用于执行等级变化效果。
function c10441498.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	local lv=e:GetLabel()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个用于改变怪兽等级的效果，并将其注册到目标怪兽上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断被解放的怪兽是否满足条件（类型为怪兽且之前在手卡或场上）。
function c10441498.thfilter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- 触发条件函数，用于判断是否满足发动条件，即是否有自己手卡或场上的怪兽被解放。
function c10441498.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10441498.thfilter2,1,e:GetHandler(),tp)
end
-- 过滤函数，用于判断墓地中是否存在满足条件的怪兽（类型为怪兽且可以加入手卡）。
function c10441498.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理函数，用于设置效果的目标选择逻辑。
function c10441498.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10441498.thfilter(chkc) end
	-- 检查是否满足发动条件，即墓地中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c10441498.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地中选择一张满足条件的怪兽。
	local g=Duel.SelectTarget(tp,c10441498.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将要将一张怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，用于执行将怪兽加入手卡的效果。
function c10441498.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
