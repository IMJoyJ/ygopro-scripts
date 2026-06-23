--輝神鳥ヴェーヌ
-- 效果：
-- 「原初的叫唤」降临。
-- ①：1回合1次，把手卡1只怪兽给对方观看，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽的等级变成和给人观看的怪兽相同。
-- ②：1回合1次，这张卡以外的自己的手卡·场上的怪兽被解放的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
function c10441498.initial_effect(c)
	-- 注册卡片记载的「原初的叫唤」卡片密码事实
	aux.AddCodeList(c,47435107)
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
-- 过滤手牌中等级在1以上、未公开且场上有其他可改变等级的怪兽的过滤函数
function c10441498.cfilter(c,tp)
	-- 判断手牌怪兽的等级是否在1以上，未公开，且场上存在可改变等级的其他怪兽作为发动判定
	return c:IsLevelAbove(1) and not c:IsPublic() and Duel.IsExistingTarget(c10441498.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 过滤场上可以成为效果对象、等级大于等于1且等级与给定等级不同的表侧表示怪兽的过滤函数
function c10441498.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 效果1的发动目标判定与参数存储（将展示的怪兽的等级记录并在场上选择符合条件的怪兽作为对象）
function c10441498.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10441498.lvfilter(chkc,e:GetLabel()) end
	-- 判定手牌中是否存在可以进行展示的合法怪兽卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c10441498.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 给玩家显示选择给对方确认卡片的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌中选择1张未公开的怪兽卡片
	local cg=Duel.SelectMatchingCard(tp,c10441498.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 向对方玩家展示玩家所选择的手牌怪兽
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切自己手牌以消除展示卡片位置后的手牌特征
	Duel.ShuffleHand(tp)
	local lv=cg:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 给玩家显示选择效果对象的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示且等级与展示怪兽不同的怪兽作为效果的对象
	Duel.SelectTarget(tp,c10441498.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lv)
end
-- 效果1的效果处理逻辑（将对象的等级修改为与所展示怪兽的等级相同，持续到回合结束）
function c10441498.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的等级修改目标怪兽（即所选的对象卡片）
	local tc=Duel.GetFirstTarget()
	local lv=e:GetLabel()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给目标怪兽注册等级改变效果，数值为展示怪兽的等级，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤被解放的怪兽是否为自己持有、原本位置在手牌或场上且是怪兽卡的过滤函数
function c10441498.thfilter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- 效果2的发动条件判定（判断是否有除自身以外的手牌或场上怪兽被解放）
function c10441498.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10441498.thfilter2,1,e:GetHandler(),tp)
end
-- 过滤自己墓地中可以加入手牌的怪兽卡过滤函数
function c10441498.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果2的发动目标判定与操作信息注册（选择自己墓地1只怪兽作为对象，并注册回收手牌的操作信息）
function c10441498.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10441498.thfilter(chkc) end
	-- 判定自己墓地中是否存在可以回收的怪兽卡作为发动的可行性判断
	if chk==0 then return Duel.IsExistingTarget(c10441498.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示将卡片回收加入手牌的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 在自己墓地中选择1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c10441498.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向系统注册效果分类信息为：加入手牌，对象为被选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果2的效果处理逻辑（将作为对象的墓地怪兽回收加入手牌）
function c10441498.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象怪兽（即所选的回收目标）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将被选中的墓地怪兽卡片以效果原因为由回收加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
