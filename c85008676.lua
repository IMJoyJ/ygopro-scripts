--剛鬼マンジロック
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方怪兽攻击的场合，那次伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成一半。
-- ②：给与自己伤害的效果由对方发动时，把这张卡从手卡丢弃才能发动（伤害步骤也能发动）。那个效果让自己受到的伤害变成一半。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 锁臂章鱼」以外的1张「刚鬼」卡加入手卡。
function c85008676.initial_effect(c)
	-- ①：对方怪兽攻击的场合，那次伤害计算时把这张卡从手卡丢弃才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85008676,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c85008676.damcon)
	e1:SetCost(c85008676.damcost)
	e1:SetOperation(c85008676.damop)
	c:RegisterEffect(e1)
	-- ②：给与自己伤害的效果由对方发动时，把这张卡从手卡丢弃才能发动（伤害步骤也能发动）。
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
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 锁臂章鱼」以外的1张「刚鬼」卡加入手卡。
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
-- 检查①效果的发动条件：自己将在这次战斗中受到战斗伤害，且进行攻击的是对方控制的怪兽
function c85008676.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己预计受到的战斗伤害大于0且攻击怪兽控制者为对方
	return Duel.GetBattleDamage(tp)>0 and Duel.GetAttacker():IsControler(1-tp)
end
-- ①②效果共用的发动代价处理：确认手卡中的这张卡可以被丢弃，并将其从手卡丢弃送去墓地
function c85008676.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 把作为效果发动源的这张卡从手卡以代价和丢弃的原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 执行①效果处理：为自己注册持续到伤害步骤结束、使本次战斗自己受到的战斗伤害减半的场上效果
function c85008676.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 为自己全局注册修改本次战斗受到战斗伤害数值的效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查②效果的发动条件：触发连锁的发动者是对方玩家，且使用通用函数判定该连锁效果将会给与自己伤害
function c85008676.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动者为对方且自己将因该连锁效果受到伤害
	return ep~=tp and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 执行②效果处理：记录所连锁效果的唯一连锁ID，为自己注册持续到连锁结束、使该连锁对自己造成的效果伤害减半的场上效果
function c85008676.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所连锁的对方给与伤害效果的唯一连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果让自己受到的伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c85008676.damval2)
	e1:SetReset(RESET_CHAIN)
	-- 为自己全局注册修改效果伤害数值的效果
	Duel.RegisterEffect(e1,tp)
end
-- 计算效果伤害变更值：若当前处于连锁处理中且伤害原因为效果伤害，当当前连锁ID与记录目标一致时将伤害减半（向下取整），否则维持原伤害值
function c85008676.damval2(e,re,val,r,rp,rc)
		-- 获取当前正在处理的连锁序号
		local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的唯一ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel() and math.floor(val/2) or val
end
-- 检查③效果的发动条件：确认送去墓地之前这张卡原本位于场上
function c85008676.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可检索的卡片：属于「刚鬼」字段、卡名不为「刚鬼 锁臂章鱼」且能够加入手卡
function c85008676.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(85008676) and c:IsAbleToHand()
end
-- ③效果的发动检查与信息设置：确认自己卡组中存在可检索的「刚鬼」卡，并登记从自己卡组将1张卡加入手卡的操作信息
function c85008676.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「刚鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c85008676.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁包含从自己卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行③效果处理：从自己卡组选择1张「刚鬼 锁臂章鱼」以外的「刚鬼」卡加入手卡，并展示给对方玩家确认
function c85008676.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家发送选择要加入手卡的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己卡组中选择1张「刚鬼 锁臂章鱼」以外的「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c85008676.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「刚鬼」卡以效果加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
