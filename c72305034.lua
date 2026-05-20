--重起士道－ゴルドナイト
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡召唤·特殊召唤成功的场合才能发动。效果文本有「二重怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。这个卡名的这个效果1回合只能使用1次。
-- ●这张卡变成机械族，攻击力上升500。
function c72305034.initial_effect(c)
	-- 为卡片添加二重怪兽的通用属性和规则（在场上·墓地当作通常怪兽，可再度召唤成为效果怪兽）
	aux.EnableDualAttribute(c)
	-- ●这张卡召唤·特殊召唤成功的场合才能发动。效果文本有「二重怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。这个卡名的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72305034,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,72305034)
	-- 设置效果发动的条件为该卡处于再度召唤的状态（二重状态）
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c72305034.thtg)
	e1:SetOperation(c72305034.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ●这张卡变成机械族，攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置该永续效果仅在卡片处于再度召唤的状态（二重状态）时适用
	e3:SetCondition(aux.IsDualState)
	e3:SetValue(RACE_MACHINE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 定义检索卡片的过滤条件：文本中记述了「二重怪兽」的魔法·陷阱卡，且能加入手卡
function c72305034.thfilter(c)
	-- 过滤出文本中含有「二重怪兽」类型记述、且是魔法或陷阱卡、并且可以加入手卡的卡片
	return aux.IsTypeInText(c,TYPE_DUAL) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义效果发动的目标，用于检测卡组中是否存在可检索的卡，并向系统宣告该效果包含检索/加入手卡的操作
function c72305034.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72305034.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统宣告该连锁将要处理的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理的具体流程：提示玩家选择、从卡组选择卡片加入手卡并给对方确认
function c72305034.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动效果的玩家从自己卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c72305034.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
