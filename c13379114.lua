--デーモンの気魄
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：额外怪兽区域有自己的「恶魔」仪式怪兽存在的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
-- ②：这张卡从手卡·场上除外的场合才能发动。从卡组把「恶魔的气魄」以外的1张「恶魔」卡加入手卡。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果和两个效果（①②）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：额外怪兽区域有自己的「恶魔」仪式怪兽存在的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡·场上除外的场合才能发动。从卡组把「恶魔的气魄」以外的1张「恶魔」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 筛选满足条件的「恶魔」仪式怪兽（在额外怪兽区域且表侧表示）
function s.cfilter(c)
	return c:GetSequence()>4 and c:IsSetCard(0x45) and c:IsType(TYPE_RITUAL)
		and c:IsFaceup()
end
-- 检查是否存在满足条件的「恶魔」仪式怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在满足条件的「恶魔」仪式怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果目标选择函数，用于选择对方场上的卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否为对方场上的卡且可成为无效化对象
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在满足条件的对方场上卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效化的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	-- 选择对方场上的1张卡作为无效化对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要无效化的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行效果处理，使目标卡的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判断此卡是否从手卡或场上除外
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 筛选满足条件的「恶魔」卡（非本卡）
function s.thfilter(c)
	return c:IsSetCard(0x45) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 设置检索效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「恶魔」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，记录将要加入手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，将卡加入手卡并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择卡组中满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
