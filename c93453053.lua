--M∀LICE IN THE MIRROR
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。从自己的手卡·场上（表侧表示）把1只「码丽丝」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
-- ②：这张卡被除外的场合，以自己墓地1张「码丽丝」卡为对象才能发动。那张卡除外，和除外的卡相同种类（怪兽·魔法·陷阱）的1张「码丽丝」卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的两个效果：①发动时无效对方怪兽并除外自身怪兽，②被除外时除外墓地卡片并检索同种类卡
function s.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。从自己的手卡·场上（表侧表示）把1只「码丽丝」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
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
	-- ②：这张卡被除外的场合，以自己墓地1张「码丽丝」卡为对象才能发动。那张卡除外，和除外的卡相同种类（怪兽·魔法·陷阱）的1张「码丽丝」卡从卡组加入手卡。
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
-- 过滤条件：手卡或场上表侧表示的、可除外的「码丽丝」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1bf)
end
-- 过滤条件：未被无效的表侧表示效果怪兽
function s.disfilter(c)
	-- 判定卡片是否为怪兽且符合可被无效的条件
	return c:IsType(TYPE_MONSTER) and aux.NegateMonsterFilter(c)
end
-- ①效果的发动准备与目标选择，检查自己手卡/场上是否有可除外的「码丽丝」怪兽，以及对方场上是否有可无效的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.disfilter(chkc) end
	-- 发动准备：检查自己手卡或场上是否存在至少1只可除外的「码丽丝」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil)
		-- 发动准备：检查对方场上是否存在至少1只可被无效的表侧表示怪兽
		and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含无效效果，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置连锁信息：包含除外效果，从自己的手卡或场上除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ①效果的处理：除外自己手卡/场上1只「码丽丝」怪兽，并无效作为对象的对方怪兽的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己手卡或场上1只「码丽丝」怪兽
	local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 成功将选中的「码丽丝」怪兽表侧表示除外
	if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与目标怪兽相关的连锁都无效化
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
-- 过滤条件：卡组中与除外卡片相同种类（怪兽/魔法/陷阱）的「码丽丝」卡
function s.thfilter(c,type)
	return c:IsSetCard(0x1bf) and c:IsAbleToHand() and c:IsType(type)
end
-- 过滤条件：自己墓地中可除外的「码丽丝」卡，且卡组中存在与其相同种类的「码丽丝」卡
function s.rmfilter(c,tp)
	return c:IsSetCard(0x1bf) and c:IsAbleToRemove()
		-- 检查卡组中是否存在与该卡相同种类（怪兽·魔法·陷阱）的「码丽丝」卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetType()&(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER))
end
-- ②效果的发动准备与目标选择，选择自己墓地1张「码丽丝」卡作为对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动准备：检查自己墓地是否存在符合条件的「码丽丝」卡
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1张「码丽丝」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置连锁信息：包含除外效果，对象为选择的墓地卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁信息：包含检索卡组效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：除外作为对象的墓地卡片，并将卡组中1张相同种类的「码丽丝」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地卡片
	local tc=Duel.GetFirstTarget()
	-- 成功将作为对象的墓地卡片表侧表示除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		local type=tc:GetType()&(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张与除外卡片相同种类的「码丽丝」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,type)
		if g:GetCount()>0 then
			-- 将选择的卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
