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
	-- 这个卡名的②的效果1回合只能使用1次。②：以这张卡以外的自己场上1只「我我我」怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的等级合计的等级。
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
-- 检索的过滤条件：卡组中满足「我我我」字段、为魔法·陷阱卡且能被加入手卡的卡。
function c387282.thfilter(c)
	return c:IsSetCard(0x54) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设置：确认卡组存在符合条件的「我我我」魔法·陷阱卡，并预宣告将进行从卡组加入手卡的处理。
function c387282.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认卡组中至少存在1张满足检索条件的「我我我」魔法·陷阱卡（且能加入手卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c387282.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 预设置操作信息：本次处理为从卡组把1张卡加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH），用于连锁与效果发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合条件的「我我我」魔法·陷阱卡加入手卡，并让对手确认。
function c387282.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示选择提示，提示文字为：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足条件的「我我我」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c387282.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，以便确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果选择对象的过滤条件：自己场上表侧表示、等级大于0、且为「我我我」怪兽。
function c387282.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x54)
end
-- ②效果发动时的取对象处理：选择自己场上这张卡以外的1只表侧表示「我我我」怪兽作为对象。
function c387282.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c387282.filter(chkc) end
	-- 发动时合法性检查：确认场上存在可以作为对象的表侧表示「我我我」怪兽（不包括这张卡本身）。
	if chk==0 then return Duel.IsExistingTarget(c387282.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给操作者显示选择提示，提示文字为：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的「我我我」怪兽作为效果对象，并将其与当前连锁/效果关联。
	Duel.SelectTarget(tp,c387282.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ②效果处理：若这张卡和对象怪兽仍与效果关联且表侧表示，则将双方的等级都变为二者当前等级之和，直到回合结束时为止。
function c387282.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 那只怪兽和这张卡直到回合结束时变成那2只的等级合计的等级。
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
