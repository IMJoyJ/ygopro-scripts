--終わりなき灰滅
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「灰灭」怪兽或「灭亡龙 威多释」加入手卡。
-- ②：以原本持有者是自己的对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那之后，可以让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
local s,id,o=GetID()
-- 初始化卡片效果：e1为魔法卡的发动效果（从墓地加入手卡），e2为在场上表侧表示存在时发动的诱发即时效果（获得控制权），并分别注册给这张卡
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「灰灭」怪兽或「灭亡龙 威多释」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以原本持有者是自己的对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那之后，可以让对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
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
-- 定义过滤函数：检索对象为「灭亡龙 威多释」（卡号78783557）或「灰灭」（0x1ad）系列的怪兽卡，且可以加入手卡
function s.thfilter(c)
	return (c:IsCode(78783557) or c:IsSetCard(0x1ad) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 发动时的效果处理：从自己墓地检索满足条件的卡，存在时询问玩家是否将其加入手卡，选择后加入手卡并让对手确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己墓地检索所有满足条件的「灰灭」怪兽或「灭亡龙 威多释」
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	-- 墓地存在满足条件的卡时，询问玩家是否将其加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从墓地加入手卡？"
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对手展示（确认）加入手卡的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义对象过滤函数：原本持有者是发动者自己、且控制权可以变更的怪兽
function s.contrfilter(c,tp)
	return c:GetOwner()==tp and c:IsControlerCanBeChanged()
end
-- 取对象阶段：确认对象在对方怪兽区域且满足条件，检查对方场上是否存在可取为对象的怪兽，选择1只作为对象并设置控制权变更的操作信息
function s.contrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.contrfilter(chkc,tp) end
	-- 发动条件检测：对方场上存在原本持有者是自己、控制权可变更的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.contrfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要变更控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.contrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置该连锁的操作信息为控制权变更（CATEGORY_CONTROL），对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获得对象怪兽的控制权，成功后可选择是否让对方场上全部表侧表示怪兽的攻击力下降对象怪兽原本攻击力的数值直到回合结束
function s.controp(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要获得控制权的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 判断对象仍与效果关联且为怪兽卡，获得其控制权成功后若其仍在怪兽区域且对方场上存在其他表侧表示怪兽，则询问玩家是否降低攻击力
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.GetControl(tc,tp)>0 and tc:IsLocation(LOCATION_MZONE) and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否降低攻击力？"
		-- 中断当前效果处理，使降低攻击力与获得控制权不视为同时处理（避免错时点）
		Duel.BreakEffect()
		-- 取得对方场上全部表侧表示怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		-- 遍历对方场上全部表侧表示怪兽，逐一施加攻击力下降效果
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
