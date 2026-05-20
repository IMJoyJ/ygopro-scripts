--剛鬼マンジロック
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方怪兽攻击的场合，那次伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成一半。
-- ②：给与自己伤害的效果由对方发动时，把这张卡从手卡丢弃才能发动（伤害步骤也能发动）。那个效果让自己受到的伤害变成一半。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 锁臂章鱼」以外的1张「刚鬼」卡加入手卡。
function c85008676.initial_effect(c)
	-- ①：对方怪兽攻击的场合，那次伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85008676,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c85008676.damcon)
	e1:SetCost(c85008676.damcost)
	e1:SetOperation(c85008676.damop)
	c:RegisterEffect(e1)
	-- ②：给与自己伤害的效果由对方发动时，把这张卡从手卡丢弃才能发动（伤害步骤也能发动）。那个效果让自己受到的伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85008676,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c85008676.damcon2)
	e2:SetCost(c85008676.damcost)
	e2:SetOperation(c85008676.damop2)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 锁臂章鱼」以外的1张「刚鬼」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85008676,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,85008676)
	e3:SetCondition(c85008676.thcon)
	e3:SetTarget(c85008676.thtg)
	e3:SetOperation(c85008676.thop)
	c:RegisterEffect(e3)
end
-- 战斗伤害减半效果的发动条件函数
function c85008676.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否会受到战斗伤害，且攻击怪兽不是自己的怪兽（即对方怪兽攻击）
	return Duel.GetBattleDamage(tp)>0 and Duel.GetAttacker()~=tp
end
-- 丢弃手牌作为发动代价的判定与执行函数
function c85008676.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡作为代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 战斗伤害减半效果的处理函数：注册一个使本次战斗伤害减半的全局效果
function c85008676.damop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：给与自己伤害的效果由对方发动时，把这张卡从手卡丢弃才能发动（伤害步骤也能发动）。那个效果让自己受到的伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使本次战斗伤害减半的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果伤害减半效果的发动条件函数
function c85008676.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的玩家是否为对方，且该效果是会给与自己伤害的效果
	return ep~=tp and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果伤害减半效果的处理函数：注册一个使该连锁的效果伤害减半的全局效果
function c85008676.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前触发效果的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 锁臂章鱼」以外的1张「刚鬼」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c85008676.damval2)
	e1:SetReset(RESET_CHAIN)
	-- 注册使该连锁的效果伤害减半的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果伤害减半的具体数值计算函数
function c85008676.damval2(e,re,val,r,rp,rc)
		-- 获取当前处理中的连锁序号
		local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel() and math.floor(val/2) or val
end
-- 检索效果的发动条件函数：此卡必须是从场上送去墓地
function c85008676.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索卡片的过滤条件：卡组中「刚鬼 锁臂章鱼」以外的「刚鬼」卡片
function c85008676.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(85008676) and c:IsAbleToHand()
end
-- 检索效果的目标确定与发动准备函数
function c85008676.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c85008676.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理函数
function c85008676.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c85008676.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
