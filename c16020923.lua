--ピカリ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「“艾”」魔法·陷阱卡加入手卡。
-- ②：以自己场上1只「@火灵天星」怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成4星。
function c16020923.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「“艾」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16020923,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16020923)
	e1:SetTarget(c16020923.thtg)
	e1:SetOperation(c16020923.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己场上1只「@火灵天星」怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16020923,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,16020924)
	e3:SetTarget(c16020923.lvtg)
	e3:SetOperation(c16020923.lvop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的魔法·陷阱卡过滤函数，条件为：属于“艾”卡组、类型为魔法或陷阱、可以加入手牌
function c16020923.thfilter(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理时的判断函数，检查是否满足发动条件：卡组中存在满足条件的魔法·陷阱卡
function c16020923.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16020923.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将满足条件的魔法·陷阱卡加入手牌的操作
function c16020923.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c16020923.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 取对象效果中目标怪兽的过滤函数，条件为：表侧表示、属于@火灵天星卡组、等级不是4、等级大于等于1
function c16020923.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135) and not c:IsLevel(4) and c:IsLevelAbove(1)
end
-- 效果处理时的判断函数，检查是否满足发动条件：自己场上存在满足条件的怪兽
function c16020923.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16020923.lvfilter(chkc) end
	-- 检查是否满足发动条件：自己场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c16020923.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c16020923.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，执行将目标怪兽等级变为4星的操作
function c16020923.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个使目标怪兽等级变为4星的效果，并在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
