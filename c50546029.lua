--Gゴーレム・ディグニファイド・トリリトン
-- 效果：
-- 地属性怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：可以攻击的对方怪兽必须向这张卡作出攻击。
-- ②：这张卡和对方怪兽进行战斗的伤害计算前1次，从手卡把1只地属性怪兽送去墓地才能发动。那只对方怪兽直到回合结束时攻击力下降200，效果无效化。
-- ③：自己场上的连接怪兽为对象的效果由对方发动时才能发动。那个效果无效并破坏。
function c50546029.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只以上地属性连接怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2)
	c:EnableReviveLimit()
	-- ①：可以攻击的对方怪兽必须向这张卡作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(c50546029.atklimit)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算前1次，从手卡把1只地属性怪兽送去墓地才能发动。那只对方怪兽直到回合结束时攻击力下降200，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50546029,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(c50546029.atkcon)
	e3:SetCost(c50546029.atkcost)
	e3:SetOperation(c50546029.atkop)
	c:RegisterEffect(e3)
	-- ③：自己场上的连接怪兽为对象的效果由对方发动时才能发动。那个效果无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50546029,1))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,50546029)
	e4:SetCondition(c50546029.discon)
	e4:SetTarget(c50546029.distg)
	e4:SetOperation(c50546029.disop)
	c:RegisterEffect(e4)
end
-- 该函数是①效果中“必须向这张卡作出攻击”的限定条件：当候选攻击对象为此卡时返回真，使对方怪兽只能选择这张卡作为攻击对象。
function c50546029.atklimit(e,c)
	return c==e:GetHandler()
end
-- ②效果的发动条件：这张卡正在进行战斗，且战斗对象是对方场上的表侧表示怪兽，并且该怪兽仍在战斗中（未离场）。
function c50546029.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
-- 用于筛选②效果作为COST送去墓地的手卡怪兽：必须是怪兽、地属性且可以作为代价送去墓地。
function c50546029.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGraveAsCost()
end
-- ②效果的COST：从手卡丢弃1只地属性怪兽；check阶段确认是否存在满足条件的卡，执行阶段进行丢弃。
function c50546029.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST合法性检测：检查手卡中是否存在至少1只可被丢弃的地属性怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50546029.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行COST：从手卡中选择并丢弃1只满足条件的地属性怪兽，丢弃原因是COST。
	Duel.DiscardHand(tp,c50546029.cfilter,1,1,REASON_COST)
end
-- ②效果处理：使战斗对象怪兽的攻击力下降200且效果无效化，持续到回合结束；处理前若该怪兽已不满足表侧表示、仍在战斗中、对方控制等条件则不处理。
function c50546029.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 使与该战斗对象怪兽相关的连锁效果无效化，并将该无效状态的重置时机设为变里侧表示时。
		Duel.NegateRelatedChain(bc,RESET_TURN_SET)
		-- 那只对方怪兽直到回合结束时攻击力下降200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(RESET_TURN_SET)
		bc:RegisterEffect(e3)
	end
end
-- 该过滤函数用于检测一张卡是否为自己场上表侧表示的连接怪兽，作为③效果中“自己场上的连接怪兽”的判定标准。
function c50546029.acfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
-- ③效果的发动条件：对方发动了以本方场上的连接怪兽为对象的效果，且这张卡未被战斗破坏。
function c50546029.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得对方发动的那组连锁中所记录的对象卡集合，用于判断其是否包含我方连接怪兽。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return rp==1-tp and tg and tg:IsExists(c50546029.acfilter,1,nil,tp)
end
-- ③效果的发动时处理：宣告将对对方效果进行无效并破坏，并根据情况设置破坏的操作信息；不发动对象。
function c50546029.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：本次效果将执行“使对方那个效果无效”的处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设定操作信息：本次效果将“破坏对方效果怪兽”，但仅当该卡可被破坏且仍与效果关联时才设定。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果的实际处理：尝试无效对方发动的效果；若无效成功且对方效果怪兽仍与效果关联，则将其破坏。
function c50546029.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：对方连锁上的效果是否被成功无效，且其发动者（卡）是否仍然与那个效果关联，两者都满足才执行破坏。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏对方发动效果的那只怪兽（eg）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
