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
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：以自己场上1只恶魔族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己的场上·墓地的「契约书」魔法·陷阱卡种类×500。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28406301)
	e1:SetTarget(c28406301.atktg)
	e1:SetOperation(c28406301.atkop)
	c:RegisterEffect(e1)
	-- ①：自己场上有「DD」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
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
-- 过滤函数，用于判断是否为正面表示的恶魔族怪兽
function c28406301.atkfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 过滤函数，用于判断是否为正面表示或在墓地的「契约书」魔法·陷阱卡
function c28406301.atkfilter2(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xae)
end
-- 设置灵摆效果的目标选择函数，用于选择自己场上的恶魔族怪兽
function c28406301.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28406301.atkfilter1(chkc) end
	-- 检查是否满足灵摆效果的发动条件，即自己场上存在恶魔族怪兽
	if chk==0 then return Duel.IsExistingTarget(c28406301.atkfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否满足灵摆效果的发动条件，即自己场上或墓地存在「契约书」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c28406301.atkfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择灵摆效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择灵摆效果的目标怪兽
	Duel.SelectTarget(tp,c28406301.atkfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置灵摆效果的处理信息，将自身设为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理函数，为选中的怪兽增加攻击力并破坏自身
function c28406301.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取灵摆效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己场上或墓地的「契约书」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c28406301.atkfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local atk=g:GetClassCount(Card.GetCode)*500
	if atk>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建攻击力提升效果，使目标怪兽获得攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsImmuneToEffect(e1) then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 破坏自身
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断是否为正面表示的「DD」怪兽
function c28406301.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 判断是否满足特殊召唤条件，即自己场上存在「DD」怪兽
function c28406301.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足特殊召唤条件，即自己场上存在「DD」怪兽
	return Duel.IsExistingMatchingCard(c28406301.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤效果的目标选择函数
function c28406301.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件，即自己场上存在空位且自身可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将自身从手卡特殊召唤
function c28406301.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以守备表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足抽卡条件，即自身为灵摆召唤
function c28406301.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤函数，用于判断是否为「DD」或「契约书」卡且可丢弃
function c28406301.drcostfilter(c)
	return c:IsSetCard(0xae,0xaf) and c:IsDiscardable()
end
-- 设置抽卡效果的费用处理函数，丢弃一张「DD」或「契约书」卡
function c28406301.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足抽卡效果的费用条件，即手牌中存在「DD」或「契约书」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28406301.drcostfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃一张「DD」或「契约书」卡作为抽卡效果的费用
	Duel.DiscardHand(tp,c28406301.drcostfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置抽卡效果的目标选择函数
function c28406301.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足抽卡效果的发动条件，即自己可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标数量
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理函数，为自己抽一张卡
function c28406301.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断是否满足从墓地特殊召唤的条件，即自身从墓地特殊召唤
function c28406301.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤函数，用于判断是否为「DD」卡且不是自身
function c28406301.thfilter(c)
	return c:IsSetCard(0xaf) and not c:IsCode(28406301) and c:IsAbleToHand()
end
-- 设置检索效果的目标选择函数
function c28406301.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索效果的发动条件，即卡组中存在符合条件的「DD」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28406301.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 检索效果的处理函数，从卡组选择一张「DD」卡加入手牌
function c28406301.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的「DD」卡
	local g=Duel.SelectMatchingCard(tp,c28406301.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
