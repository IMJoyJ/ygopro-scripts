--重の忍者－磁翁
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤·反转的场合，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。这个效果变成里侧守备表示的对方场上的怪兽不能把表示形式变更。
-- ②：这张卡已在怪兽区域表侧表示存在的状态，场上的怪兽反转的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（召唤、特殊召唤、反转时将场上最多2只表侧怪兽变成里侧守备表示，且对方怪兽不能变更表示形式）和②效果（场上怪兽反转时破坏对方场上1张卡）。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤·反转的场合，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。这个效果变成里侧守备表示的对方场上的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	-- ②：这张卡已在怪兽区域表侧表示存在的状态，场上的怪兽反转的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"对方1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_FLIP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- ①效果的Target函数：检查并选择场上最多2只表侧表示怪兽作为对象。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
	-- 检查场上是否存在至少1只可以变成里侧守备表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示当前操作玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1到2只可以变成里侧守备表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 设置当前连锁的操作信息为改变表示形式，涉及卡片为选择的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
-- ①效果的Operation函数：将作为对象的怪兽变成里侧守备表示，并使其中变成里侧守备表示的对方场上怪兽不能变更表示形式。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 遍历所有符合条件的对象怪兽。
	for tc in aux.Next(g) do
		if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
			-- 将目标怪兽变成里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
			if tc:IsPosition(POS_FACEDOWN_DEFENSE) and tc:IsControler(1-tp) then
				-- 这个效果变成里侧守备表示的对方场上的怪兽不能把表示形式变更。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
-- ②效果的发动条件：场上的怪兽反转，且反转的怪兽不包括这张卡自身。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
-- ②效果的Target函数：选择对方场上1张卡作为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示当前操作玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏，涉及卡片为选择的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的Operation函数：破坏作为对象的卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在效果处理时仍与连锁相关，则将其因效果破坏。
	if tc:IsRelateToChain() then Duel.Destroy(tc,REASON_EFFECT) end
end
