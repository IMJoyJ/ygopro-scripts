--プリンシパグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以原本卡名包含「守护者」的自己场上1只不能通常召唤的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽加入手卡。
-- ●把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：以原本卡名包含「守护者」的自己场上1只不能通常召唤的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 判断是否处于可以进行战斗相关操作的时点或阶段
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(s.bttg)
	e1:SetOperation(s.btop)
	c:RegisterEffect(e1)
	-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将此卡从游戏中除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg1)
	e2:SetOperation(s.thop1)
	c:RegisterEffect(e2)
	-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 将此卡从游戏中除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否满足①效果的条件
function s.bfilter(c)
	return c:IsFaceup() and not c:IsSummonableCard() and c:IsSetCard(0x52) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- ①效果的目标选择函数
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.bfilter(chkc) end
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的怪兽作为①效果的目标
	Duel.SelectTarget(tp,s.bfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果的处理函数
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给目标怪兽增加1次攻击次数
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断墓地中的卡是否与目标怪兽有卡名记述关系
function s.thfilter(c,mc)
	-- 判断卡是否能加入手牌且与目标怪兽有卡名记述关系
	return c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 过滤函数，用于判断墓地中的怪兽是否满足②效果的发动条件
function s.tgfilter(c,check,tp)
	if c:IsSummonableCard() or not c:IsSetCard(0x52) then
		return false
	else
		if check then
			-- 检查是否存在满足条件的卡可以加入手牌
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,c)
		else
			return c:IsAbleToHand()
		end
	end
end
-- ②效果的第一个选项的目标选择函数
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查是否满足②效果第一个选项的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的怪兽作为②效果第一个选项的目标
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，准备将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的第一个选项的处理函数
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果第一个选项的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽加入手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- ②效果的第二个选项的目标选择函数
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,true,tp) end
	-- 检查是否满足②效果第二个选项的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),true,tp) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的怪兽作为②效果第二个选项的目标
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,true,tp)
	-- 设置操作信息，准备将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的第二个选项的处理函数
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果第二个选项的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
