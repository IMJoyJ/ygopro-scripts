--M∀LICE IN THE MIRROR
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。从自己的手卡·场上（表侧表示）把1只「码丽丝」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
-- ②：这张卡被除外的场合，以自己墓地1张「码丽丝」卡为对象才能发动。那张卡除外，和除外的卡相同种类（怪兽·魔法·陷阱）的1张「码丽丝」卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册速攻魔法发动的①效果（除外「码丽丝」怪兽并无效对方怪兽效果）与自身被除外触发的②效果（除外墓地并检索同类「码丽丝」卡）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以对方场上1只表侧表示怪兽为对象才能发动。从自己的手卡·场上（表侧表示）把1只「码丽丝」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡被除外的场合，以自己墓地1张「码丽丝」卡为对象才能发动。那张卡除外，和除外的卡相同种类（怪兽·魔法·陷阱）的1张「码丽丝」卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件函数：筛选手卡或场上表侧表示的、可被除外的「码丽丝」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1bf)
end
-- 过滤条件函数：筛选表侧表示且当前效果未被无效的效果怪兽
function s.disfilter(c)
	-- 检查该卡是否为怪兽卡且满足可被无效效果的表侧效果怪兽条件
	return c:IsType(TYPE_MONSTER) and aux.NegateMonsterFilter(c)
end
-- ①效果的目标选择与检查函数：确认自己手卡·场上有可除外的「码丽丝」怪兽且对方场上有可无效的怪兽，选择1只对方怪兽为对象并登记无效与除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.disfilter(chkc) end
	-- 发动条件检查：确认自己怪兽区（表侧表示）或手卡中至少存在1只可除外的「码丽丝」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil)
		-- 检查对方怪兽区是否存在至少1只可成为对象的表侧表示效果怪兽
		and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示：请选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方怪兽区选择1只可无效效果的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向系统登记操作信息：将会使所选对象的1只怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 向系统登记操作信息：将会从自己怪兽区·手卡除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ①效果的处理函数：从自己手卡·场上表侧表示选择1只「码丽丝」怪兽除外，若成功进入除外区则将对象怪兽的相关连锁与场上效果直到回合结束时无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象选择的对方怪兽
	local tc=Duel.GetFirstTarget()
	-- 向玩家发送选择提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己怪兽区（表侧表示）或手卡选择1只可除外的「码丽丝」怪兽
	local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 以效果表侧除外选中的「码丽丝」怪兽，并确认其成功进入除外区
	if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与对象怪兽相关的当前连锁效果无效化（若变里侧则重置）
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 作为对象的怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件函数：筛选卡组中与指定卡片种类相同且可加入手卡的「码丽丝」卡
function s.thfilter(c,type)
	return c:IsSetCard(0x1bf) and c:IsAbleToHand() and c:IsType(type)
end
-- 过滤条件函数：筛选墓地中可除外的「码丽丝」卡，且卡组存在与其同种类（怪兽·魔法·陷阱）的可检索「码丽丝」卡
function s.rmfilter(c,tp)
	return c:IsSetCard(0x1bf) and c:IsAbleToRemove()
		-- 检查自己卡组是否存在至少1张与该卡相同种类（怪兽/魔法/陷阱）且可加入手卡的「码丽丝」卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetType()&(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER))
end
-- ②效果的目标选择与检查函数：确认自己墓地存在符合条件的「码丽丝」卡，选择1张作为对象并登记除外与检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter(chkc,tp) end
	-- 发动条件检查：确认自己墓地存在至少1张可成为对象的符合条件的「码丽丝」卡
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家发送选择提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张符合条件的「码丽丝」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 向系统登记操作信息：将会除外所选对象的1张墓地卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 向系统登记操作信息：将会从自己卡组检索1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：将墓地对象卡除外，随后从卡组选1张同种类的「码丽丝」卡加入手卡并展示确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象选择的自己墓地「码丽丝」卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联则以效果表侧除外，并在成功除外后继续检索处理
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		local type=tc:GetType()&(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
		-- 向玩家发送选择提示：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己卡组选择1张与被除外卡同种类的「码丽丝」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,type)
		if g:GetCount()>0 then
			-- 以效果将检索到的「码丽丝」卡加入自己手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示确认加入手卡的「码丽丝」卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
