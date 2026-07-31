--白騎士団のロード
local s,id,o=GetID()
-- 卡片初始化函数，注册卡片记载的相关卡片代码，以及卡片手牌特召与二选一后续处理、攻击宣言时将对方攻击力变为0、被破坏时给予对方伤害这三个效果。
function s.initial_effect(c)
	-- 注册卡片记载的代码49306994，用于相关效果检索和检测提示。
	aux.AddCodeList(c,49306994)
	-- 注册效果①：从墓地把3只怪兽除外才能发动（手牌起动效果，1回合1次）。这张卡特殊召唤，之后可以从手牌·卡组特召1只「白骑士团」怪兽或从卡组把1张「白骑士团」相关卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 注册效果②：这张卡与对方怪兽进行战斗的攻击宣言时强制发动的诱发效果，那只对方怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- 注册效果③：场上的这张卡被对方破坏的场合发动的诱发效果，给对方给予1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 代价过滤函数，检查墓地中的卡是否为怪兽且可以作为代价除外。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果①的代价函数，检查并从墓地把3只怪兽除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少3只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 显示选择除外目标的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择3只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的3只怪兽表侧表示除外以支付发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的目标选择函数，检查怪兽区域空位以及自身能否特殊召唤，并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空置的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤分类，目标卡为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤过滤函数，检查卡片是否属于「白骑士团」系列（0x1e9）且能被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索过滤函数，检查卡片代码是否为49306994且能加入手牌。
function s.thfilter(c)
	return c:IsCode(49306994) and c:IsAbleToHand()
end
-- 效果①的操作执行函数，将这张卡特殊召唤，之后根据玩家选择执行从手牌/卡组特召白骑士团怪兽或检索指定卡加入手牌。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身与连锁是否仍相关并成功表侧表示特殊召唤到场上。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查自己场上是否有空置怪兽区域，作为后续特殊召唤分支的判断条件之一。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手牌或卡组中是否存在可以特殊召唤的「白骑士团」怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		-- 检查卡组中是否存在可以加入手牌的指定卡片（49306994）。
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local op=0
		if b1 or b2 then
			-- 提示玩家选择后续要执行的操作分支（不执行/特召白骑士团怪兽/检索特定卡）。
			op=aux.SelectFromOptions(tp,
				{true,aux.Stringid(id,3),0},
				{b1,aux.Stringid(id,4),1},
				{b2,aux.Stringid(id,5),2})
		end
		if op~=0 then
			-- 插入效果结算间隔（断效果），隔离特殊召唤自身与后续效果的处理。
			Duel.BreakEffect()
		end
		if op==1 then
			-- 显示选择特殊召唤目标的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手牌或卡组中选择1只符合条件的「白骑士团」怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽表侧表示特殊召唤到场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			-- 显示选择加入手牌目标的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1张指定卡片（49306994）。
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的卡片通过效果加入手牌。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手牌的卡片组。
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- 效果②的目标选择函数，在攻击宣言时判断自身是否处于战斗状态，并选择战斗的对方怪兽为目标。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取当前攻击宣言的攻击怪兽。
		local a=Duel.GetAttacker()
		-- 获取当前攻击宣言的被攻击怪兽。
		local at=Duel.GetAttackTarget()
		return (a==c and at or at==c)
			and not c:IsStatus(STATUS_CHAINING)
	end
	-- 获取并设置与自身战斗的对方怪兽为效果目标。
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- 效果②的操作执行函数，确认目标怪兽有效后将该对方怪兽的攻击力变为0。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对方战斗怪兽目标。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(1-tp) and tc:GetAttack()>0 then
		-- 注册攻击力变更效果：将目标怪兽的攻击力变为0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的发动条件函数，检查卡片是否因对方的效果或战斗被破坏且原本由自己控制。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 效果③的目标选择函数，设置目标玩家为对方、伤害数值为1000，并设置伤害分类操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果作用的目标玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果作用的参数数值为1000。
	Duel.SetTargetParam(1000)
	-- 设置操作信息为给予对方1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果③的操作执行函数，获取目标玩家和伤害参数，对对方玩家造成1000点伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家和伤害数值参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果伤害处理，给予目标玩家指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
