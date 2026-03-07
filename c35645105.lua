--無限起動ハーヴェスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「无限起动 收割机」以外的1只「无限起动」怪兽加入手卡。
-- ②：以这张卡以外的自己场上1只机械族怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
function c35645105.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「无限起动 收割机」以外的1只「无限起动」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35645105,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,35645105)
	e1:SetTarget(c35645105.thtg)
	e1:SetOperation(c35645105.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只机械族怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35645105,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,35645106)
	e3:SetTarget(c35645105.lvtg)
	e3:SetOperation(c35645105.lvop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「无限起动」怪兽（非本卡）加入手牌的过滤函数
function c35645105.thfilter(c)
	return c:IsSetCard(0x127) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(35645105)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并设置连锁信息
function c35645105.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35645105.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：将要处理的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c35645105.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c35645105.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选场上可作为对象的机械族怪兽的过滤函数
function c35645105.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(0)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并设置连锁信息
function c35645105.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc~=c and chkc:IsLocation(LOCATION_MZONE) and c35645105.lvfilter(chkc) end
	-- 判断是否满足发动条件：场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c35645105.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c35645105.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果处理函数，执行等级变更的操作
function c35645105.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=c:GetOriginalLevel()+tc:GetOriginalLevel()
		c35645105.setlv(c,c,lv)
		c35645105.setlv(c,tc,lv)
	end
end
-- 设置等级变更效果的函数
function c35645105.setlv(c,ec,lv)
	-- 设置等级变更效果，使目标怪兽等级变为指定值
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(lv)
	ec:RegisterEffect(e1)
end
