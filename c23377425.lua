--S－Force ブリッジヘッド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「治安战警队」怪兽加入手卡。
-- ②：对方怪兽向相同纵列的自己的「治安战警队」怪兽攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
function c23377425.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「治安战警队」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23377425+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c23377425.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽向相同纵列的自己的「治安战警队」怪兽攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
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
-- 检索满足条件的「治安战警队」怪兽卡片组
function c23377425.thfilter(c)
	return c:IsSetCard(0x156) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：从卡组检索1只「治安战警队」怪兽加入手牌
function c23377425.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组卡片组
	local g=Duel.GetMatchingGroup(c23377425.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否满足发动条件并询问玩家是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(23377425,0)) then  --"是否从卡组把1只「治安战警队」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断是否满足②效果发动条件
function c23377425.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local ac=Duel.GetAttacker()
	-- 获取此次战斗的攻击目标怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local cg=ac:GetColumnGroup()
	e:SetLabelObject(bc)
	return ac:IsControler(1-tp) and cg:IsContains(bc) and bc:IsFaceup() and bc:IsSetCard(0x156) and bc:IsControler(tp)
end
-- 设置②效果的发动目标
function c23377425.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsRelateToBattle() end
end
-- 效果处理：使目标怪兽不会被那次战斗破坏
function c23377425.indop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsRelateToBattle() and bc:IsControler(tp) then
		-- 使目标怪兽在战斗步骤中不会被破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e1)
	end
end
