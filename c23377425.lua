--S－Force ブリッジヘッド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「治安战警队」怪兽加入手卡。
-- ②：对方怪兽向相同纵列的自己的「治安战警队」怪兽攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
function c23377425.initial_effect(c)
	-- 对应效果原文：『这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「治安战警队」怪兽加入手卡。』
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23377425+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c23377425.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：『这个卡名的②的效果1回合只能使用1次。②：对方怪兽向相同纵列的自己的「治安战警队」怪兽攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23377425,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,23377426)
	e2:SetCondition(c23377425.indcon)
	e2:SetTarget(c23377425.indtg)
	e2:SetOperation(c23377425.indop)
	c:RegisterEffect(e2)
end
-- 检索过滤器：判断一张卡是否为『治安战警队』字段的怪兽，且能够加入手卡，用于①效果检索卡组。
function c23377425.thfilter(c)
	return c:IsSetCard(0x156) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动处理：从卡组筛选符合条件的『治安战警队』怪兽，玩家确认后选择1张加入手卡，并向对方展示该卡。
function c23377425.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足thfilter过滤条件的『治安战警队』怪兽卡，作为本次检索的候选集合。
	local g=Duel.GetMatchingGroup(c23377425.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若候选卡组非空且玩家选择“是”确认检索，则继续执行检索处理；否则效果处理不检索。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(23377425,0)) then  --"是否从卡组把1只「治安战警队」怪兽加入手卡？"
		-- 向玩家显示选择提示（请选择要加入手牌的卡），为后续从候选卡中选择卡片作界面准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的『治安战警队』怪兽以「效果」的原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将检索加入手卡的那张卡展示给对方玩家确认，确保对方看到检索到的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的发动条件判定：对方怪兽进行攻击宣言，且被攻击的己方表侧表示『治安战警队』怪兽与攻击怪兽处于同一纵列；同时将被攻击的己方怪兽记录到效果的LabelObject，满足全部条件时返回true。
function c23377425.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽（即对方攻击怪兽）。
	local ac=Duel.GetAttacker()
	-- 获取被攻击宣言指定的攻击对象（即己方受到攻击的『治安战警队』怪兽）。
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local cg=ac:GetColumnGroup()
	e:SetLabelObject(bc)
	return ac:IsControler(1-tp) and cg:IsContains(bc) and bc:IsFaceup() and bc:IsSetCard(0x156) and bc:IsControler(tp)
end
-- ②效果的发动时点确认：检查记录的己方怪兽是否仍与本次战斗关联（未离场或未失去战斗关联），若仍关联则允许效果发动。
function c23377425.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsRelateToBattle() end
end
-- ②效果处理：对仍与本次战斗关联的己方『治安战警队』怪兽赋予直到伤害步骤结束前不会被战斗破坏的效果。
function c23377425.indop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsRelateToBattle() and bc:IsControler(tp) then
		-- 对应效果原文：『那只自己怪兽不会被那次战斗破坏。』
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e1)
	end
end
