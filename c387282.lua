--ガガガシスター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1张「我我我」魔法·陷阱卡加入手卡。
-- ②：以这张卡以外的自己场上1只「我我我」怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的等级合计的等级。
function c387282.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「我我我」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(387282,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c387282.thtg)
	e1:SetOperation(c387282.thop)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的自己场上1只「我我我」怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的等级合计的等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(387282,1))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,387282)
	e2:SetTarget(c387282.lvtg)
	e2:SetOperation(c387282.lvop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组，筛选出「我我我」魔法·陷阱卡
function c387282.thfilter(c)
	return c:IsSetCard(0x54) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息，准备从卡组检索1张「我我我」魔法·陷阱卡
function c387282.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在至少1张「我我我」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c387282.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定要处理的卡为卡组中的1张魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果，选择并把符合条件的卡加入手牌
function c387282.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c387282.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选场上满足条件的「我我我」怪兽，即表侧表示且等级大于0
function c387282.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x54)
end
-- 设置效果处理时的连锁操作信息，准备选择目标怪兽
function c387282.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c387282.filter(chkc) end
	-- 检查是否满足选择目标条件，即自己场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c387282.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c387282.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 处理等级变化效果，将选定的怪兽和自身等级相加并设置为新的等级
function c387282.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 创建等级变化效果，使目标怪兽等级变为两者等级之和
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
