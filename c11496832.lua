--プリンシパグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以原本卡名包含「守护者」的自己场上1只不能通常召唤的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽加入手卡。
-- ●把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡。
local s,id,o=GetID()
-- 注册①②效果
function s.initial_effect(c)
	-- ①：以原本卡名包含「守护者」的自己场上1只不能通常召唤的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 检查是否可以进入战斗阶段或正处于战斗阶段
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(s.bttg)
	e1:SetOperation(s.btop)
	c:RegisterEffect(e1)
	-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"作为对象的怪兽加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为 cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg1)
	e2:SetOperation(s.thop1)
	c:RegisterEffect(e2)
	-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。●把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"作为对象的怪兽有卡名记述的卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为 cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤原本卡名包含「守护者」的自己场上表侧表示不能通常召唤且未拥有追加攻击效果的怪兽
function s.bfilter(c)
	return c:IsFaceup() and not c:IsSummonableCard() and c:IsSetCard(0x52) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- ①效果的 Target 函数：选择自己场上1只原本卡名包含「守护者」的不能通常召唤的怪兽为对象
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.bfilter(chkc) end
	-- 检查自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只原本卡名包含「守护者」的不能通常召唤的怪兽为对象
	Duel.SelectTarget(tp,s.bfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果的 Operation 函数：赋予对象怪兽同一战斗阶段可作2次攻击的效果
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤在指定怪兽卡名有记述且可以加入手卡的卡
function s.thfilter(c,mc)
	-- 检查卡片是否可以加入手卡且在目标怪兽卡名有记述
	return c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 过滤自己墓地不能通常召唤的「守护者」怪兽（及判断是否有满足条件的卡）
function s.tgfilter(c,check,tp)
	if c:IsSummonableCard() or not c:IsSetCard(0x52) or not c:IsType(TYPE_MONSTER) then
		return false
	else
		if check then
			-- 检查墓地是否存在其卡名记述的卡
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,c)
		else
			return c:IsAbleToHand()
		end
	end
end
-- ②效果分支1的 Target 函数：以自己墓地1只不能通常召唤的「守护者」怪兽为对象
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查墓地是否存在满足条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只不能通常召唤的「守护者」怪兽为对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果分支1的 Operation 函数：将作为对象的怪兽加入手卡
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 作为对象的怪兽加入手卡。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- ②效果分支2的 Target 函数：以自己墓地1只不能通常召唤的「守护者」怪兽为对象
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,true,tp) end
	-- 检查墓地是否存在满足条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),true,tp) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只不能通常召唤的「守护者」怪兽为对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,true,tp)
	-- 设置操作信息：将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果分支2的 Operation 函数：把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张在作为对象的怪兽有卡名记述的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡。
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
