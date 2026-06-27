--魔降雷
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示的「0x45」怪兽为对象才能发动。那只怪兽的攻击力上升600。那之后，可以把对方场上的原本攻击力比这只怪兽的攻击力低的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只攻击力2500·等级6的恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 墓地效果的Cost：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤表侧表示的「0x45」系列怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 效果发动时的条件检查与锁定
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 确认自己场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 锁定自己场上的1只怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤原本攻击力低于指定数值的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk
end
-- 主效果的实际操作：提升攻击力并可选择破坏对方攻击力较低的所有怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升600
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 瞬时调整并刷新场上状态
		Duel.AdjustAll()
		local atk=tc:GetAttack()
		-- 检查对方场上是否存在原本攻击力比该怪兽当前攻击力低的可破坏怪兽
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)
			-- 询问玩家是否破坏对方场上所有原本攻击力较低的怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 切分效果时点
			Duel.BreakEffect()
			-- 获取对方场上所有符合被破坏条件的怪兽
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
			-- 将这些怪兽全部破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 回收怪兽过滤：墓地中攻击力为2500且等级为6的恶魔族怪兽
function s.thfilter(c)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsAbleToHand()
end
-- 回收效果的条件检查与锁定
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 确认墓地中是否存在符合条件的回收对象
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 锁定墓地中符合条件的怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 声明将怪兽加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的实际操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将该怪兽回收至手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方确认回收的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
