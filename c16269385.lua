--プランキッズ・ハウス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「调皮宝贝」怪兽加入手卡。
-- ②：1回合1次，自己对「调皮宝贝」融合怪兽的融合召唤成功的场合才能发动。自己场上的全部怪兽的攻击力上升500。
-- ③：1回合1次，自己对「调皮宝贝」连接怪兽的连接召唤成功的场合才能发动。对方场上的全部怪兽的攻击力下降500。
function c16269385.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「调皮宝贝」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16269385+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c16269385.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己对「调皮宝贝」融合怪兽的融合召唤成功的场合才能发动。自己场上的全部怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16269385,1))  --"自己全部怪兽攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c16269385.atkcon)
	e2:SetTarget(c16269385.atktg)
	e2:SetOperation(c16269385.atkop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己对「调皮宝贝」连接怪兽的连接召唤成功的场合才能发动。对方场上的全部怪兽的攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16269385,2))  --"对方全部怪兽攻击力下降"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16269385.atkcon2)
	e3:SetTarget(c16269385.atktg2)
	e3:SetOperation(c16269385.atkop2)
	c:RegisterEffect(e3)
end
-- 定义检索筛选函数：卡片必须是怪兽卡，且属于「调皮宝贝」系列字段，并且能够加入手卡，才能作为①效果从卡组检索的对象。
function c16269385.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x120) and c:IsAbleToHand()
end
-- ①效果的发动时处理：从卡组中筛选出符合条件的「调皮宝贝」怪兽；若存在且玩家选择发动检索，则提示选卡，将选中的1张加入手卡，并向对方展示。
function c16269385.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取所有满足thfilter筛选条件的「调皮宝贝」怪兽，作为本次检索的候选卡组。
	local g=Duel.GetMatchingGroup(c16269385.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若候选卡组不为空，且玩家选择“是”（即决定进行检索），则继续执行后面的选卡和加入手卡操作。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16269385,0)) then  --"是否把「调皮宝贝」怪兽加入手卡？"
		-- 向玩家发送“请选择要加入手牌的卡”的选择提示，用于后续从候选卡组中选择1张卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「调皮宝贝」怪兽以效果原因送入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认，确保信息公开。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义特殊召唤成功怪兽的筛选条件：该怪兽必须是表侧表示、属于「调皮宝贝」系列、召唤类型为指定类型（融合或连接），并且其召唤玩家是tp。
function c16269385.cfilter(c,tp,sumt)
	return c:IsFaceup() and c:IsSetCard(0x120) and c:IsSummonType(sumt) and c:IsSummonPlayer(tp)
end
-- ②效果的触发条件：本次特殊召唤成功的怪兽组中，存在至少1只由tp以融合召唤方式特殊召唤的表侧表示「调皮宝贝」怪兽。
function c16269385.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16269385.cfilter,1,nil,tp,SUMMON_TYPE_FUSION)
end
-- ②效果的发动目标检查：己方场上必须存在至少1只表侧表示怪兽，才能发动该效果（用于后续给己方全部怪兽上升攻击力）。
function c16269385.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在至少1只表侧表示怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果处理：获取己方场上的全部表侧表示怪兽，为每一只怪兽临时赋予攻击力上升500的效果。
function c16269385.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方场上的全部表侧表示怪兽，作为攻击力上升的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 遍历上一步获取的己方表侧表示怪兽组，依次对每只怪兽施加攻击力上升效果。
	for tc in aux.Next(g) do
		-- 自己场上的全部怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的触发条件：本次特殊召唤成功的怪兽组中，存在至少1只由tp以连接召唤方式特殊召唤的表侧表示「调皮宝贝」怪兽。
function c16269385.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16269385.cfilter,1,nil,tp,SUMMON_TYPE_LINK)
end
-- ③效果的发动目标检查：对方场上必须存在至少1只表侧表示怪兽，才能发动该效果（用于后续给对方场上全部怪兽下降攻击力）。
function c16269385.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ③效果处理：获取对方场上的全部表侧表示怪兽，为每一只怪兽临时赋予攻击力下降500的效果。
function c16269385.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的全部表侧表示怪兽，作为攻击力下降的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历上一步获取的对方表侧表示怪兽组，依次对每只怪兽施加攻击力下降效果。
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
