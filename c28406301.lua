--DDグリフォン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己场上1只恶魔族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己的场上·墓地的「契约书」魔法·陷阱卡种类×500。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②③的怪兽效果1回合各能使用1次。
-- ①：自己场上有「DD」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：这张卡灵摆召唤的场合，从手卡丢弃1张「DD」卡或「契约书」卡才能发动。自己抽1张。
-- ③：这张卡从墓地特殊召唤的场合才能发动。从卡组把「DD 狮鹫」以外的1张「DD」卡加入手卡。
function c28406301.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（支持灵摆召唤、灵摆卡发动等）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以自己场上1只恶魔族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己的场上·墓地的「契约书」魔法·陷阱卡种类×500。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28406301)
	e1:SetTarget(c28406301.atktg)
	e1:SetOperation(c28406301.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②③的怪兽效果1回合各能使用1次。①：自己场上有「DD」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28406301,0))  --"从手卡守备表示特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,28406302)
	e2:SetCondition(c28406301.spcon)
	e2:SetTarget(c28406301.sptg)
	e2:SetOperation(c28406301.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡灵摆召唤的场合，从手卡丢弃1张「DD」卡或「契约书」卡才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28406301,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,28406303)
	e3:SetCondition(c28406301.drcon)
	e3:SetCost(c28406301.drcost)
	e3:SetTarget(c28406301.drtg)
	e3:SetOperation(c28406301.drop)
	c:RegisterEffect(e3)
	-- ③：这张卡从墓地特殊召唤的场合才能发动。从卡组把「DD 狮鹫」以外的1张「DD」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28406301,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,28406304)
	e4:SetCondition(c28406301.thcon)
	e4:SetTarget(c28406301.thtg)
	e4:SetOperation(c28406301.thop)
	c:RegisterEffect(e4)
end
-- 灵摆效果①的对象筛选条件：自己场上表侧表示且种族为恶魔族的怪兽。
function c28406301.atkfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 灵摆效果①计算攻击力时使用的卡筛选条件：自己场上表侧表示或墓地里的「契约书」魔法·陷阱卡。
function c28406301.atkfilter2(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xae)
end
-- 灵摆效果①的发动条件与取对象处理：确认自己场上有可选的表侧恶魔族怪兽且场上/墓地存在「契约书」卡；后续选择对象时限定为自己场上的表侧恶魔族怪兽。
function c28406301.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28406301.atkfilter1(chkc) end
	-- 检查自己场上是否存在1只表侧表示的恶魔族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c28406301.atkfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认自己场上或墓地存在至少1张「契约书」魔法·陷阱卡，以满足效果发动条件。
		and Duel.IsExistingMatchingCard(c28406301.atkfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择对象的提示信息（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只表侧恶魔族怪兽作为效果对象。
	Duel.SelectTarget(tp,c28406301.atkfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本连锁后续会破坏这张卡自身，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的结算：统计自己场上·墓地的「契约书」魔法·陷阱卡种类数×500作为攻击力上升值，对对象怪兽赋予攻击力上升效果；若处理有效且对象不免疫该效果，则破坏这张卡。
function c28406301.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回灵摆效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取自己场上·墓地的所有「契约书」魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c28406301.atkfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local atk=g:GetClassCount(Card.GetCode)*500
	if atk>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升自己的场上·墓地的「契约书」魔法·陷阱卡种类×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsImmuneToEffect(e1) then
			-- 中断当前效果处理，使随后的破坏处理与攻击力上升处理成为不同时机。
			Duel.BreakEffect()
			-- 以效果破坏这张卡（灵摆区中的自身）。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 怪兽效果①的筛选条件：自己场上表侧表示的「DD」怪兽。
function c28406301.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 怪兽效果①的发动条件：自己场上有「DD」怪兽存在。
function c28406301.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只表侧表示「DD」怪兽。
	return Duel.IsExistingMatchingCard(c28406301.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 怪兽效果①的发动目标：确认自己主要怪兽区有空位，且这张卡可以从手卡以表侧守备表示特殊召唤。
function c28406301.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本效果将把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的结算：若这张卡仍与效果关联，则将其从手卡以表侧守备表示特殊召唤到自己场上。
function c28406301.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 怪兽效果②的发动条件：这张卡以灵摆召唤方式成功特殊召唤。
function c28406301.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 怪兽效果②的cost筛选条件：手卡中1张「DD」卡或「契约书」卡，且可以被丢弃。
function c28406301.drcostfilter(c)
	return c:IsSetCard(0xae,0xaf) and c:IsDiscardable()
end
-- 怪兽效果②的cost：从手卡丢弃1张「DD」卡或「契约书」卡。
function c28406301.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在1张「DD」卡或「契约书」卡可作为cost丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c28406301.drcostfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际从手卡丢弃1张符合条件的「DD」卡或「契约书」卡作为cost。
	Duel.DiscardHand(tp,c28406301.drcostfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 怪兽效果②的目标：确认自己可以抽1张卡，并记录目标玩家和抽卡数。
function c28406301.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 记录效果的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 记录抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本连锁将进行抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 怪兽效果②的结算：根据记录的目标玩家和抽卡数进行抽卡。
function c28406301.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的抽卡目标玩家和抽卡数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽取对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 怪兽效果③的发动条件：这张卡从墓地成功特殊召唤。
function c28406301.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 怪兽效果③的检索卡筛选条件：卡组中「DD 狮鹫」以外的「DD」卡且能被加入手卡。
function c28406301.thfilter(c)
	return c:IsSetCard(0xaf) and not c:IsCode(28406301) and c:IsAbleToHand()
end
-- 怪兽效果③的发动目标：确认卡组中有符合条件的「DD」卡，并设置操作信息。
function c28406301.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张符合条件的「DD」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c28406301.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 怪兽效果③的结算：从卡组选择1张符合条件的「DD」卡加入手卡，并向对方玩家确认。
function c28406301.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「DD」卡。
	local g=Duel.SelectMatchingCard(tp,c28406301.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
