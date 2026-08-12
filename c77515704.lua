--ドラゴンメイド・リラクゼーション
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以以自己场上1只「半龙女仆」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽回到手卡，从卡组把「半龙女仆的休息」以外的1张「半龙女仆」卡加入手卡。
-- ●作为对象的怪兽回到手卡，对方场上1张魔法·陷阱卡回到手卡。
function c77515704.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：可以以自己场上1只「半龙女仆」怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽回到手卡，从卡组把「半龙女仆的休息」以外的1张「半龙女仆」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77515704,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,77515704)
	e2:SetTarget(c77515704.thtg1)
	e2:SetOperation(c77515704.thop1)
	c:RegisterEffect(e2)
	-- ①：可以以自己场上1只「半龙女仆」怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽回到手卡，对方场上1张魔法·陷阱卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(77515704,1))  --"魔陷返回手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,77515704)
	e4:SetTarget(c77515704.thtg2)
	e4:SetOperation(c77515704.thop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示且能回到手卡的「半龙女仆」怪兽
function c77515704.thfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x133) and c:IsAbleToHand()
end
-- 过滤条件：卡组中「半龙女仆的休息」以外且能加入手卡的「半龙女仆」卡
function c77515704.thfilter2(c)
	return c:IsSetCard(0x133) and not c:IsCode(77515704) and c:IsAbleToHand()
end
-- 效果1（检索效果）的发动准备与合法性检测
function c77515704.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c77515704.thfilter1(chkc) end
	-- 检查自己场上是否存在可以作为对象的「半龙女仆」怪兽
	if chk==0 then return Duel.IsExistingTarget(c77515704.thfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在可以检索的「半龙女仆」卡
		and Duel.IsExistingMatchingCard(c77515704.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只「半龙女仆」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77515704.thfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息：将包含对象怪兽和卡组中1张卡在内的共2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,tp,LOCATION_DECK)
end
-- 效果1（检索效果）的效果处理
function c77515704.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽因效果成功回到手卡，则继续处理后续效果
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「半龙女仆的休息」以外的「半龙女仆」卡
		local g=Duel.SelectMatchingCard(tp,c77515704.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤条件：场上能回到手卡的魔法·陷阱卡
function c77515704.thfilter3(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果2（弹魔陷效果）的发动准备与合法性检测
function c77515704.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c77515704.thfilter1(chkc) end
	-- 检查自己场上是否存在可以作为对象的「半龙女仆」怪兽
	if chk==0 then return Duel.IsExistingTarget(c77515704.thfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以返回手卡的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c77515704.thfilter3,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只「半龙女仆」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77515704.thfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息：将包含对象怪兽和对方场上1张卡在内的共2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,1-tp,LOCATION_ONFIELD)
end
-- 效果2（弹魔陷效果）的效果处理
function c77515704.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽因效果成功回到手卡，则继续处理后续效果
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上1张魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c77515704.thfilter3,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的对方魔陷卡送回手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
