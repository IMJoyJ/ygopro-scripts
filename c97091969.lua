--武装竜の震霆
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以以自己场上1只「武装龙」怪兽为对象，从以下效果选择1个发动。
-- ●那只怪兽的攻击力上升那只怪兽的等级×100。
-- ●从自己墓地选持有那只怪兽的等级以下的等级的1只「武装龙」怪兽加入手卡。
-- ②：自己场上的「武装龙」怪兽被效果破坏的场合，可以作为代替把这张卡送去墓地。
function c97091969.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：可以以自己场上1只「武装龙」怪兽为对象，从以下效果选择1个发动。●那只怪兽的攻击力上升那只怪兽的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97091969,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,97091969)
	e1:SetTarget(c97091969.target)
	e1:SetOperation(c97091969.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(97091969,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetTarget(c97091969.thtg)
	e2:SetOperation(c97091969.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「武装龙」怪兽被效果破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c97091969.reptg)
	e3:SetOperation(c97091969.repop)
	e3:SetValue(c97091969.repval)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示且有等级的「武装龙」怪兽
function c97091969.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x111) and c:IsLevelAbove(1)
end
-- 效果①（攻击力上升）的发动准备与对象选择
function c97091969.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97091969.filter(chkc) end
	-- 检查自己场上是否存在满足条件的「武装龙」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c97091969.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「武装龙」怪兽作为对象
	Duel.SelectTarget(tp,c97091969.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①（攻击力上升）的效果处理
function c97091969.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升那只怪兽的等级×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的「武装龙」怪兽，且自己墓地存在等级在其之下的可加入手牌的「武装龙」怪兽
function c97091969.tgfilter(c,tp)
	-- 判断怪兽是否为表侧表示的「武装龙」怪兽，且其等级大于等于墓地中某只「武装龙」怪兽的等级
	return c:IsFaceup() and c:IsSetCard(0x111) and c:IsLevelAbove(1) and Duel.IsExistingMatchingCard(c97091969.thfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetLevel())
end
-- 过滤条件：墓地中等级在指定数值以下且可以加入手牌的「武装龙」怪兽
function c97091969.thfilter(c,lv)
	return c:IsSetCard(0x111) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
-- 效果①（墓地回收）的发动准备与对象选择
function c97091969.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97091969.tgfilter(chkc,tp) end
	-- 检查自己场上是否存在满足回收条件的「武装龙」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c97091969.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「武装龙」怪兽作为对象
	Duel.SelectTarget(tp,c97091969.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置将墓地的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①（墓地回收）的效果处理
function c97091969.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己墓地选择1只持有对象怪兽等级以下等级的「武装龙」怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97091969.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc:GetLevel())
		if #g>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤条件：自己场上因效果破坏的表侧表示「武装龙」怪兽
function c97091969.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x111) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动准备与条件判断
function c97091969.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and c:IsAbleToGrave() and eg:IsExists(c97091969.repfilter,1,nil,tp) end
	-- 询问玩家是否使用此卡代替破坏
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的处理
function c97091969.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 确定代替破坏效果所适用的卡片范围
function c97091969.repval(e,c)
	return c97091969.repfilter(c,e:GetHandlerPlayer())
end
