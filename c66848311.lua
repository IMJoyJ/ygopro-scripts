--終わりなき灰滅
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「灰灭」怪兽或「灭亡龙 威多释」加入手卡。
-- ②：以原本持有者是自己的对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那之后，可以让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
local s,id,o=GetID()
-- 注册卡片效果：①卡片发动时的效果处理；②在魔陷区发动的自由时点诱发即时效果。
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「灰灭」怪兽或「灭亡龙 威多释」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：以原本持有者是自己的对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那之后，可以让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"获得控制权"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.contrtg)
	e2:SetOperation(s.controp)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中的「灭亡龙 威多释」或「灰灭」怪兽，且可以加入手卡。
function s.thfilter(c)
	return (c:IsCode(78783557) or c:IsSetCard(0x1ad) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- ①效果的发动处理：可以从自己墓地选择1只符合条件的怪兽加入手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有符合条件的「灰灭」怪兽或「灭亡龙 威多释」。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	-- 若墓地存在符合条件的卡，则询问玩家是否选择将其加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从墓地加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：原本持有者是自己且可以转移控制权的对方场上怪兽。
function s.contrfilter(c,tp)
	return c:GetOwner()==tp and c:IsControlerCanBeChanged()
end
-- ②效果的对象选择与发动准备：确认场上是否存在符合条件的怪兽，并将其设为效果对象。
function s.contrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.contrfilter(chkc,tp) end
	-- 检查对方场上是否存在至少1只原本持有者是自己的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.contrfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只原本持有者是自己的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.contrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息，表示此效果包含控制权转移的操作。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ②效果的处理：尝试获得目标怪兽的控制权，若成功，可选择让对方场上所有表侧表示怪兽的攻击力下降该怪兽的原本攻击力数值。
function s.controp(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果且成功转移控制权，且对方场上存在表侧表示怪兽，则询问玩家是否降低对方怪兽的攻击力。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.GetControl(tc,tp) and tc:IsLocation(LOCATION_MZONE) and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否降低攻击力？"
		-- 中断当前效果处理，使后续的攻击力下降处理与获得控制权不视为同时处理。
		Duel.BreakEffect()
		-- 获取对方场上当前所有的表侧表示怪兽。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		-- 遍历对方场上所有的表侧表示怪兽。
		for ac in aux.Next(g) do
			-- 让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-tc:GetBaseAttack())
			ac:RegisterEffect(e1)
		end
	end
end
