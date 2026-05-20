--轟の王 ハール
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：「轰界王战 哈尔王」在自己场上只能有1只表侧表示存在。
-- ②：1回合1次，对方在抽卡阶段以外从卡组把卡加入手卡的场合才能发动。对方必须把自身的手卡·场上1只怪兽送去墓地。
-- ③：魔法·陷阱·怪兽的效果发动时，把自己场上的「王战」怪兽或者魔法师族怪兽合计2只解放才能发动。那个发动无效并破坏。
function c68199168.initial_effect(c)
	c:SetUniqueOnField(1,0,68199168)
	-- ②：1回合1次，对方在抽卡阶段以外从卡组把卡加入手卡的场合才能发动。对方必须把自身的手卡·场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68199168,0))  --"怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c68199168.tgcon)
	e1:SetTarget(c68199168.tgtg)
	e1:SetOperation(c68199168.tgop)
	c:RegisterEffect(e1)
	-- ③：魔法·陷阱·怪兽的效果发动时，把自己场上的「王战」怪兽或者魔法师族怪兽合计2只解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68199168,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,68199168)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c68199168.discon)
	e2:SetCost(c68199168.discost)
	e2:SetTarget(c68199168.distg)
	e2:SetOperation(c68199168.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：属于指定玩家且原本位置在卡组的卡片
function c68199168.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果②的发动条件：当前不是抽卡阶段，且对方有卡片从卡组加入手卡
function c68199168.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否不是抽卡阶段，且加入手卡的卡片中是否存在对方从卡组加入手卡的卡
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(c68199168.cfilter,1,nil,1-tp)
end
-- 过滤条件：未确认（非公开）的卡片，或者是怪兽卡
function c68199168.tgfilter(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 效果②的发动准备与可行性检测：检查对方场上是否有怪兽，或者对方手卡中是否存在未公开的卡或怪兽卡，并设置送去墓地的操作信息
function c68199168.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽数量
	local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 获取对方的手卡卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return mc>0 or g and g:IsExists(c68199168.tgfilter,1,nil) end
	-- 设置连锁运营信息：预计将对方手卡或场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE+LOCATION_HAND)
end
-- 效果②的效果处理：对方选择自身手卡或场上的1只怪兽送去墓地
function c68199168.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡及场上所有的怪兽卡
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_MZONE+LOCATION_HAND,0,nil,TYPE_MONSTER)
	if g:GetCount()>0 then
		-- 给对方玩家发送提示信息：“请选择要送去墓地的卡”
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 选中卡片的视觉提示（若选中的是场上的怪兽，则在场上闪烁显示）
		Duel.HintSelection(sg)
		-- 对方玩家因规则（非效果）将选中的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- 效果③的发动条件：此卡在场上表侧表示存在（未被战斗破坏），且有可以被无效的连锁效果发动
function c68199168.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身未被战斗破坏，且当前发动的效果可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：属于「王战」系列或者种族为魔法师族的卡片
function c68199168.costfilter(c)
	return c:IsSetCard(0x134) or c:IsRace(RACE_SPELLCASTER)
end
-- 效果③的代价处理：检查并解放自己场上的2只「王战」怪兽或魔法师族怪兽
function c68199168.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否存在至少2只满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c68199168.costfilter,2,nil) end
	-- 给自己玩家发送提示信息：“请选择要解放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2张满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c68199168.costfilter,2,2,nil)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果③的发动准备与可行性检测：设置无效发动与破坏的操作信息
function c68199168.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁运营信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁运营信息：如果发动的卡可以被破坏且仍存在于对应区域，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果③的效果处理：使发动的效果无效并破坏该卡
function c68199168.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该效果的发动无效，且该卡与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
