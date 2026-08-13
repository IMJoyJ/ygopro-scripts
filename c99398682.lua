--クリムゾン・ヘルコール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把1只4星以下的恶魔族怪兽加入手卡。自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在的场合，也能从卡组选加入手卡的怪兽。
-- ②：自己的「/爆裂体」怪兽或「红莲魔龙」攻击的伤害步骤结束时，把墓地的这张卡除外才能发动。那只攻击怪兽只再1次可以继续攻击。
local s,id,o=GetID()
-- 定义本卡的初始效果注册：既注册作为魔法卡发动时的①检索效果，也注册墓地中的②再次攻击效果，并包含1回合1次的发动限制。
function s.initial_effect(c)
	-- 将「红莲魔龙」的卡号70902743登记到本卡的卡名记述列表中，用于配合“有那个卡名记述的同调怪兽”的判定。
	aux.AddCodeList(c,70902743)
	-- ①：从自己墓地把1只4星以下的恶魔族怪兽加入手卡。自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在的场合，也能从卡组选加入手卡的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「/爆裂体」怪兽或「红莲魔龙」攻击的伤害步骤结束时，把墓地的这张卡除外才能发动。那只攻击怪兽只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"再次攻击"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	-- 设置②效果的发动代价：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数s.cfilter，用于判断己方场上是否存在表侧表示的「红莲魔龙」或卡名记述了「红莲魔龙」的同调怪兽。
function s.cfilter(c)
	-- 具体过滤条件：怪兽表侧表示，且（卡号为70902743，或是卡名记述了70902743的同调怪兽）。
	return c:IsFaceup() and (c:IsCode(70902743) or aux.IsCodeListed(c,70902743) and c:IsType(TYPE_SYNCHRO))
end
-- 定义检索目标过滤函数s.thfilter：需为4星以下恶魔族且能加入手牌；当res为真（场上有红莲魔龙/记述同调怪）时允许从卡组选择，否则只能从墓地选择。
function s.thfilter(c,res)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(4) and c:IsAbleToHand()
		and (res or not c:IsLocation(LOCATION_DECK))
end
-- 定义e1的发动条件判断s.target：检查发动时是否存在符合条件的检索目标，并判断是否允许从卡组检索，同时设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在至少1张满足s.cfilter的怪兽，结果赋给res，作为可否从卡组检索的依据。
	local res=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 在发动时（chk==0）确认卡组+墓地中是否存在至少1张满足s.thfilter（带res判断）的怪兽，作为发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,res) end
	-- 设置操作信息：本次效果将1张卡加入手牌，涉及区域为卡组+墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义e1的效果处理s.activate：再次确认条件后，从卡组/墓地选择符合条件的1只恶魔族怪兽加入手牌，并向对方展示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查己方场上是否存在满足s.cfilter的怪兽，以决定本次检索是否允许从卡组选卡。
	local res=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 显示“选择要加入手牌的卡”的提示消息，供玩家选择时查看。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组+墓地中选择1张满足s.thfilter且不受王家长眠之谷影响的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,res)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手牌，原因标记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义e2的发动条件s.atkcon：伤害步骤结束时，若攻击怪兽为己方控制的「/爆裂体」怪兽或「红莲魔龙」，且该怪兽仍与战斗相关并可继续攻击，则满足条件。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在攻击的怪兽。
	local tc=Duel.GetAttacker()
	return tc:IsControler(tp) and (tc:IsSetCard(0x104f) or tc:IsCode(70902743)) and tc:IsRelateToBattle()
		and tc:IsChainAttackable()
end
-- 定义e2的效果处理s.atkop：让那只攻击怪兽获得一次额外的攻击机会。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行Duel.ChainAttack()，使当前攻击怪兽可以再次攻击。
	Duel.ChainAttack()
end
