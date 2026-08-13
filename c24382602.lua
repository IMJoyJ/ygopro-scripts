--光の霊堂
-- 效果：
-- ①：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性·1星调整召唤。
-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只通常怪兽送去墓地，作为对象的怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的等级×100。
-- ③：把墓地的这张卡除外才能发动。从卡组把1张「毁灭之爆裂疾风弹」加入手卡。
function c24382602.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性·1星调整召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24382602,0))  --"使用「光之灵堂」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(c24382602.extg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只通常怪兽送去墓地，作为对象的怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的等级×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c24382602.atktg)
	e3:SetOperation(c24382602.atkop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。从卡组把1张「毁灭之爆裂疾风弹」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	-- 设置③效果的发动代价：把墓地的这张卡除外（使用 aux.bfgcost 作为费用函数）。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c24382602.thtg)
	e4:SetOperation(c24382602.thop)
	c:RegisterEffect(e4)
end
-- ①效果的额外召唤对象过滤条件：目标怪兽必须是光属性、1星且为调整怪兽。
function c24382602.extg(e,c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1)
end
-- ②效果的取对象过滤器：选择自己场上的表侧表示怪兽。
function c24382602.tgfilter(c)
	return c:IsFaceup()
end
-- ②效果的送墓过滤器：从手卡·卡组选择通常怪兽（通常怪兽且能够送去墓地）。
function c24382602.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动条件判定与取对象：检查是否存在1只表侧表示怪兽可作为对象，且手卡·卡组中有通常怪兽可送去墓地；在取对象阶段（chkc）校验所选择对象是否合法。
function c24382602.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c24382602.tgfilter(chkc) end
	-- 发动时（chk==0）检查自己场上是否存在1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c24382602.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并检查手卡·卡组中是否存在1只满足条件的通常怪兽可以送去墓地。
		and Duel.IsExistingMatchingCard(c24382602.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只自己场上的表侧表示怪兽作为效果对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c24382602.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：效果处理时会从手卡·卡组将1只怪兽送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：从手卡·卡组选择1只通常怪兽送去墓地，若成功且对象仍表侧表示，则令对象怪兽攻击力·守备力直到回合结束时上升那只怪兽等级×100。
function c24382602.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的通常怪兽（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡·卡组选择1只满足条件的通常怪兽作为送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,c24382602.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		local lv=gc:GetLevel()
		-- 确认通常怪兽已成功被效果送去墓地并仍存在于墓地，且对象怪兽仍与效果关联、处于表侧表示时，才继续处理能力值上升。
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 作为对象的怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的等级×100。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(lv*100)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end
-- ③效果的检索过滤器：卡组中卡号为17655904的「毁灭之爆裂疾风弹」，且能够加入手卡。
function c24382602.thfilter(c)
	return c:IsCode(17655904) and c:IsAbleToHand()
end
-- ③效果的发动条件与操作信息：检查卡组中是否存在「毁灭之爆裂疾风弹」，并设置效果处理时回手牌的操作信息。
function c24382602.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查卡组中是否存在1张「毁灭之爆裂疾风弹」且能够加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24382602.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时从卡组将1张卡加入手卡（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1张「毁灭之爆裂疾风弹」加入手卡，并向对方玩家确认。
function c24382602.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「毁灭之爆裂疾风弹」。
	local g=Duel.SelectMatchingCard(tp,c24382602.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
