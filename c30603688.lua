--幻想の見習い魔導師
-- 效果：
-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「黑魔术师」加入手卡。
-- ③：自己·对方回合，其他的自己的魔法师族·暗属性怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力只在那次伤害计算时上升2000。
function c30603688.initial_effect(c)
	-- 将这张卡加入记述「黑魔术师」的卡名列表，用于效果记载检索（如「黑魔术师」相关卡）中识别关联卡。
	aux.AddCodeList(c,46986414)
	-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c30603688.spcon)
	e1:SetTarget(c30603688.sptg)
	e1:SetOperation(c30603688.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「黑魔术师」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30603688,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c30603688.thtg)
	e2:SetOperation(c30603688.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合，其他的自己的魔法师族·暗属性怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力只在那次伤害计算时上升2000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30603688,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e4:SetCondition(c30603688.atkcon)
	e4:SetCost(c30603688.atkcost)
	e4:SetOperation(c30603688.atkop)
	c:RegisterEffect(e4)
end
-- 定义规则特殊召唤的判定函数：当尝试用此规则特殊召唤时，检查己方主要怪兽区是否有空位，以及手牌是否有除自身以外可作为丢弃代价的卡；c为nil时视为可召唤。
function c30603688.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方主要怪兽区存在可用空格，确保能空出位置进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方手牌存在至少1张除自身以外的卡，以满足“丢弃1张手卡”的代价条件。
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,c)
end
-- 定义规则特殊召唤的目标选择函数：从手牌中筛选可丢弃的卡（排除自身），提示玩家选择1张，选中后存入效果标签对象并返回true以继续特殊召唤处理；未选择则返回false。
function c30603688.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取己方手牌中除这张卡以外所有可以丢弃的卡，作为待选丢弃代价的候选组。
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	-- 向玩家显示“请选择要丢弃的手牌”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义规则特殊召唤的处理函数：将目标选择阶段暂存的1张手牌以“特殊召唤+丢弃”的原因送去墓地，完成规则特殊召唤所需的丢弃代价。
function c30603688.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为代价选择的手牌送去墓地，原因标记为特殊召唤和丢弃。
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end
-- 定义检索过滤条件：卡片必须是卡号46986414的「黑魔术师」，并且能够被加入手牌。
function c30603688.filter(c)
	return c:IsCode(46986414) and c:IsAbleToHand()
end
-- 定义②效果的发动目标判定：检查卡组是否存在可检索的「黑魔术师」，若有则登记本次操作为从卡组加入手牌的检索效果。
function c30603688.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点判定阶段（chk==0）检查卡组是否存在至少1张符合条件的「黑魔术师」，确保检索对象存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30603688.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记当前连锁的操作信息，标明效果处理时会把卡组中的1张卡加入手牌，分类为回手牌和检索。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果的处理：玩家从卡组选择1只符合条件的「黑魔术师」加入手牌，并向对方玩家展示检索到的卡。
function c30603688.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张符合条件的「黑魔术师」作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c30603688.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡加入其持有者的手牌，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义③效果的发动条件：在伤害计算时，获取正在与对方怪兽战斗的己方其他魔法师族·暗属性怪兽，排除这张卡自身，并且该怪兽处于战斗相关状态。
function c30603688.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击目标怪兽（可能为nil）。
	local c=Duel.GetAttackTarget()
	if not c then return false end
	-- 若攻击目标由对方控制，则改用攻击怪兽作为己方战斗怪兽，从而锁定符合条件的那只己方怪兽。
	if c:IsControler(1-tp) then c=Duel.GetAttacker() end
	e:SetLabelObject(c)
	return c and c~=e:GetHandler() and c:IsRace(RACE_SPELLCASTER)
		and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRelateToBattle()
end
-- 定义③效果的代价：检查这张卡是否可以作为代价从手牌或场上送去墓地；若能则将其送去墓地。
function c30603688.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡自身送去墓地，作为发动③效果支付的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义③效果的处理：若目标怪兽仍表侧表示且与战斗相关，则在其攻击力、守备力上各上升2000点，用于本次伤害计算。
function c30603688.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToBattle() then
		-- 那只自己怪兽的攻击力·守备力只在那次伤害计算时上升2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(2000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
