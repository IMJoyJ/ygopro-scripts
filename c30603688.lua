--幻想の見習い魔導師
-- 效果：
-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「黑魔术师」加入手卡。
-- ③：自己·对方回合，其他的自己的魔法师族·暗属性怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力只在那次伤害计算时上升2000。
function c30603688.initial_effect(c)
	-- 记录该卡具有「黑魔术师」这张卡的卡片密码
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
-- 判断特殊召唤条件是否满足：场地有空位且手牌有可丢弃的卡
function c30603688.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断手牌是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌是否存在至少一张可丢弃的卡
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,c)
end
-- 设置特殊召唤时的选择处理：选择一张手牌丢弃
function c30603688.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有可丢弃的卡
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的丢弃操作：将选择的卡送去墓地
function c30603688.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡以特殊召唤+丢弃原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end
-- 定义检索卡牌的过滤条件：卡号为黑魔术师且可加入手牌
function c30603688.filter(c)
	return c:IsCode(46986414) and c:IsAbleToHand()
end
-- 设置检索效果的处理：检查卡组是否存在黑魔术师
function c30603688.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的黑魔术师
	if chk==0 then return Duel.IsExistingMatchingCard(c30603688.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息：将一张黑魔术师加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果：从卡组选择一张黑魔术师加入手牌
function c30603688.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择一张满足条件的黑魔术师
	local g=Duel.SelectMatchingCard(tp,c30603688.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将目标卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足攻击力提升效果的发动条件：战斗怪兽为魔法师族且暗属性
function c30603688.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击方或防守方的怪兽
	local c=Duel.GetAttackTarget()
	if not c then return false end
	-- 若防守方为对方，则获取攻击方怪兽
	if c:IsControler(1-tp) then c=Duel.GetAttacker() end
	e:SetLabelObject(c)
	return c and c~=e:GetHandler() and c:IsRace(RACE_SPELLCASTER)
		and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRelateToBattle()
end
-- 设置攻击力提升效果的费用：将自身送去墓地
function c30603688.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身以费用原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 执行攻击力提升效果：使目标怪兽攻击力与守备力上升2000
function c30603688.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToBattle() then
		-- 创建攻击力提升效果并注册到目标怪兽
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
