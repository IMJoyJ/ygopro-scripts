--終わりなき灰滅
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「灰灭」怪兽或「灭亡龙 威多释」加入手卡。
-- ②：以原本持有者是自己的对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那之后，可以让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「灰灭」怪兽或「灭亡龙 威多释」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：以原本持有者是自己的对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。
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
-- 过滤自己墓地中满足「灰灭」怪兽或「灭亡龙 威多释」且能加入手牌的卡
function s.thfilter(c)
	return (c:IsCode(78783557) or c:IsSetCard(0x1ad) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 作为卡片发动时的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地所有满足过滤条件的「灰灭」怪兽或「灭亡龙 威多释」
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	-- 若墓地有符合条件的卡，则询问玩家是否发动将其加入手牌的效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从墓地加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤原本持有者是自己且可以改变控制权的怪兽
function s.contrfilter(c,tp)
	return c:GetOwner()==tp and c:IsControlerCanBeChanged()
end
-- 控制权转移效果的发动检测与对象选择
function s.contrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.contrfilter(chkc,tp) end
	-- 检测对方场上是否存在符合条件的可被选择为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.contrfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.contrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理的信息为改变1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 控制权转移与降低攻击力的效果处理函数
function s.controp(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽依然存在且成功获得控制权，且对方场上存在表侧表示怪兽，则询问是否下降对方场上怪兽的攻击力
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.GetControl(tc,tp)>0 and tc:IsLocation(LOCATION_MZONE) and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否降低攻击力？"
		-- 中断效果处理，使后续的下降攻击力不与获得控制权同时进行
		Duel.BreakEffect()
		-- 获取对方场上所有的表侧表示怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		-- 遍历对方场上的所有表侧表示怪兽进行处理
		for ac in aux.Next(g) do
			-- 可以让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-tc:GetBaseAttack())
			ac:RegisterEffect(e1)
		end
	end
end
