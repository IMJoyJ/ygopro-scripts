--ファイアウォール・ドラゴン・ダークフルード
-- 效果：
-- 效果怪兽3只以上
-- ①：这张卡连接召唤的场合才能发动。自己墓地的电子界族怪兽种类（仪式·融合·同调·超量）数量的指示物给这张卡放置。
-- ②：这张卡的攻击力在战斗阶段内上升这张卡的指示物数量×2500。
-- ③：对方把怪兽的效果发动时，把这张卡1个指示物取除才能发动。那个发动无效。这个效果在从这张卡的攻击宣言时到伤害步骤结束时发动的场合，这张卡再1次可以继续攻击。
function c68934651.initial_effect(c)
	c:EnableCounterPermit(0x52)
	-- 为这张卡添加连接召唤手续，需要3只以上的连接素材，且素材必须是效果怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。自己墓地的电子界族怪兽种类（仪式·融合·同调·超量）数量的指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68934651,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c68934651.ctcon)
	e1:SetTarget(c68934651.cttg)
	e1:SetOperation(c68934651.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力在战斗阶段内上升这张卡的指示物数量×2500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c68934651.atkcon)
	e2:SetValue(c68934651.atkval)
	c:RegisterEffect(e2)
	-- ③：对方把怪兽的效果发动时，把这张卡1个指示物取除才能发动。那个发动无效。这个效果在从这张卡的攻击宣言时到伤害步骤结束时发动的场合，这张卡再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68934651,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c68934651.discon)
	e3:SetCost(c68934651.discost)
	e3:SetTarget(c68934651.distg)
	e3:SetOperation(c68934651.disop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡连接召唤成功
function c68934651.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：检查卡片是否为电子界族且属于指定的怪兽种类（仪式/融合/同调/超量）
function c68934651.cfilter(c,type)
	return c:IsRace(RACE_CYBERSE) and c:IsType(type)
end
-- 效果①的发动准备：计算自己墓地中电子界族怪兽种类（仪式·融合·同调·超量）的数量，并确认这张卡是否能放置对应数量的指示物
function c68934651.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	for i,type in ipairs({TYPE_FUSION,TYPE_RITUAL,TYPE_SYNCHRO,TYPE_XYZ}) do
		-- 检查自己墓地是否存在至少1张满足特定种类（仪式/融合/同调/超量）的电子界族怪兽
		if Duel.IsExistingMatchingCard(c68934651.cfilter,tp,LOCATION_GRAVE,0,1,nil,type) then
			ct=ct+1
		end
	end
	if chk==0 then return ct>0 and e:GetHandler():IsCanAddCounter(0x52,ct) end
end
-- 效果①的效果处理：计算自己墓地中电子界族怪兽种类（仪式·融合·同调·超量）的数量，并给这张卡放置相同数量的指示物
function c68934651.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local ct=0
	for i,type in ipairs({TYPE_FUSION,TYPE_RITUAL,TYPE_SYNCHRO,TYPE_XYZ}) do
		-- 检查自己墓地是否存在至少1张满足特定种类（仪式/融合/同调/超量）的电子界族怪兽
		if Duel.IsExistingMatchingCard(c68934651.cfilter,tp,LOCATION_GRAVE,0,1,nil,type) then
			ct=ct+1
		end
	end
	if ct>0 then
		c:AddCounter(0x52,ct)
	end
end
-- 效果②的适用条件：当前处于战斗阶段
function c68934651.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 效果②的攻击力上升值计算：这张卡的指示物数量乘以2500
function c68934651.atkval(e,c)
	return c:GetCounter(0x52)*2500
end
-- 效果③的发动条件：对方把怪兽的效果发动时，且这张卡不在战斗破坏确定状态，且该发动可以被无效
function c68934651.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动的怪兽效果、自身未被战斗破坏、且该连锁的发动可以被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 效果③的发动代价：取除这张卡的1个指示物
function c68934651.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x52,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x52,1,REASON_COST)
end
-- 效果③的发动准备：设置无效发动的操作信息，并记录发动时这张卡是否为攻击怪兽（用于后续追加攻击的判定）
function c68934651.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 判断当前进行攻击宣言的怪兽是否为这张卡自身
	if Duel.GetAttacker()==e:GetHandler() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 效果③的效果处理：使该发动无效，若是在这张卡攻击宣言时到伤害步骤结束时发动的，则这张卡可以再1次继续攻击
function c68934651.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
	if e:GetLabel()==1 and c:IsRelateToEffect(e) and c:IsChainAttackable(0) then
		-- 使这张卡可以再1次继续攻击
		Duel.ChainAttack()
	end
end
