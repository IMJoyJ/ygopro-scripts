--D-HERO ディシジョンガイ
-- 效果：
-- 「命运英雄 决意人」的①③的效果在决斗中各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，选自己墓地1只「英雄」怪兽加入手卡。
-- ②：6星以上的对方怪兽不能选择这张卡作为攻击对象。
-- ③：这张卡在墓地存在，给与自己伤害的魔法·陷阱·怪兽的效果发动时发动。这张卡回到手卡，那个效果让自己受到的伤害变成0。
function c64184058.initial_effect(c)
	-- ②：6星以上的对方怪兽不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c64184058.atlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，选自己墓地1只「英雄」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,64184058+EFFECT_COUNT_CODE_DUEL)
	e2:SetOperation(c64184058.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在，给与自己伤害的魔法·陷阱·怪兽的效果发动时发动。这张卡回到手卡，那个效果让自己受到的伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_F)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,64184059+EFFECT_COUNT_CODE_DUEL)
	-- 设置效果的发动条件为：给与自己伤害的魔法、陷阱、怪兽的效果发动时
	e4:SetCondition(aux.damcon1)
	e4:SetTarget(c64184058.damtg)
	e4:SetOperation(c64184058.damop)
	c:RegisterEffect(e4)
end
-- 攻击限制的过滤函数：判断攻击怪兽是否为对方控制且等级在6星以上
function c64184058.atlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(1-tp) and c:IsLevelAbove(6) and not c:IsImmuneToEffect(e)
end
-- 过滤函数：用于检索自己墓地的「英雄」怪兽
function c64184058.thfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 召唤·特殊召唤成功时的效果处理：注册一个在结束阶段发动的延迟效果
function c64184058.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，选自己墓地1只「英雄」怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c64184058.thcon)
	e1:SetOperation(c64184058.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段回收手牌的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段回收效果的发动条件：自己墓地存在可以加入手牌的「英雄」怪兽
function c64184058.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在满足条件的「英雄」怪兽
	return Duel.IsExistingMatchingCard(c64184058.thfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段回收效果的操作：选择自己墓地1只「英雄」怪兽加入手牌
function c64184058.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在决斗界面显示「命运英雄 决意人」的卡片发动提示
	Duel.Hint(HINT_CARD,0,64184058)
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己墓地1张满足过滤条件且不受「王家长眠之谷」影响的「英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64184058.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 在场上/墓地显式示出所选择的卡片
		Duel.HintSelection(g)
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 墓地效果的发动准备：确认效果处理时将此卡加入手牌
function c64184058.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将自身加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地效果的操作：将自身回到手牌，并注册一个使该次效果伤害变成0的临时效果
function c64184058.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与效果关联，且成功回到手牌
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 判断当前连锁是否紧随造成伤害的效果之后（确保没有被其他效果插队）
		and Duel.GetCurrentChain()==ev+1 then
		-- 获取造成伤害的效果所在的连锁ID
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 那个效果让自己受到的伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c64184058.damval)
		e1:SetReset(RESET_CHAIN)
		-- 将伤害变更效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害变更效果的数值计算函数：如果是对应连锁的效果伤害，则将伤害值变为0
function c64184058.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前处理连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
