--メガロイド都市
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从卡组把1张「机人」卡加入手卡。
-- ②：自己的「机人」怪兽进行战斗的伤害计算时，从卡组把1只「机人」怪兽送去墓地才能发动。那只进行战斗的自己怪兽只在那次伤害计算时原本攻击力和原本守备力交换。
function c44139064.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从卡组把1张「机人」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44139064,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,44139064)
	e2:SetCost(c44139064.descost)
	e2:SetTarget(c44139064.destg)
	e2:SetOperation(c44139064.desop)
	c:RegisterEffect(e2)
	-- ②：自己的「机人」怪兽进行战斗的伤害计算时，从卡组把1只「机人」怪兽送去墓地才能发动。那只进行战斗的自己怪兽只在那次伤害计算时原本攻击力和原本守备力交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44139064,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCountLimit(1,44139065)
	e3:SetCondition(c44139064.atkcon)
	e3:SetCost(c44139064.atkcost)
	e3:SetTarget(c44139064.atktg)
	e3:SetOperation(c44139064.atkop)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录玩家在回合中是否已经发动过融合怪兽以外的特殊召唤效果
	Duel.AddCustomActivityCounter(44139064,ACTIVITY_SPSUMMON,c44139064.counterfilter)
end
-- 计数器的过滤函数，判断卡片是否为融合怪兽或不是从额外卡组召唤
function c44139064.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 特殊召唤限制函数，禁止非融合怪兽从额外卡组特殊召唤
function c44139064.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的费用支付函数，检查是否在本回合中已经发动过非融合怪兽的特殊召唤效果，并设置禁止特殊召唤的效果
function c44139064.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在本回合中已经发动过非融合怪兽的特殊召唤效果
	if chk==0 then return Duel.GetCustomActivityCount(44139064,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个禁止特殊召唤的效果，该效果在回合结束时自动清除
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44139064.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 检索卡组中「机人」卡的过滤函数
function c44139064.thfilter(c)
	return c:IsSetCard(0x16) and c:IsAbleToHand()
end
-- 效果①的目标选择函数，检查场上是否存在满足条件的卡和卡组中是否存在「机人」卡
function c44139064.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=e:GetHandler() end
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查卡组中是否存在「机人」卡
		and Duel.IsExistingMatchingCard(c44139064.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，指定要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，破坏目标卡并从卡组检索一张「机人」卡加入手牌
function c44139064.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否有效并进行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择一张「机人」卡
		local g=Duel.SelectMatchingCard(tp,c44139064.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果②的发动条件函数，检查是否为「机人」怪兽进行战斗
function c44139064.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		-- 获取攻击目标怪兽
		a=Duel.GetAttackTarget()
	end
	return a and a:IsSetCard(0x16)
end
-- 检索卡组中「机人」怪兽的过滤函数
function c44139064.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16) and c:IsAbleToGraveAsCost()
end
-- 效果②的费用支付函数，检查卡组中是否存在「机人」怪兽并支付其作为费用
function c44139064.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「机人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44139064.atkfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查是否在本回合中已经发动过非融合怪兽的特殊召唤效果
		and Duel.GetCustomActivityCount(44139064,tp,ACTIVITY_SPSUMMON)==0 end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一只「机人」怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c44139064.atkfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 创建并注册一个禁止特殊召唤的效果，该效果在回合结束时自动清除
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44139064.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的目标设置函数，设置进行战斗的怪兽为连锁目标
function c44139064.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		-- 获取攻击目标怪兽
		a=Duel.GetAttackTarget()
	end
	-- 设置连锁目标为攻击怪兽
	Duel.SetTargetCard(a)
end
-- 效果②的处理函数，交换攻击怪兽的攻击力和守备力
function c44139064.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=tg:GetFirst()
	if tc:IsRelateToBattle() and tc:IsControler(tp) then
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 创建并注册一个修改攻击力的效果，将目标怪兽的攻击力设为原本守备力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(bdef)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(batk)
		tc:RegisterEffect(e2)
	end
end
