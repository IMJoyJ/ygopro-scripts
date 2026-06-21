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
	-- 这个卡名的①的效果1回合能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从卡组把1张「机人」卡加入手卡。
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
	-- 这个卡名的②的效果1回合能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。②：自己的「机人」怪兽进行战斗的伤害计算时，从卡组把1只「机人」怪兽送去墓地才能发动。那只进行战斗的自己怪兽只在那次伤害计算时原本攻击力和原本守备力交换。
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
	-- 添加特殊召唤的自定义活动计数器，用于监控从额外卡组特殊召唤的怪兽是否为融合怪兽
	Duel.AddCustomActivityCounter(44139064,ACTIVITY_SPSUMMON,c44139064.counterfilter)
end
-- 计数器过滤函数：若特殊召唤的怪兽不是来自额外卡组，或者是表侧表示的融合怪兽，则不计入计数
function c44139064.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 特殊召唤限制函数：限制玩家不能特殊召唤融合怪兽以外的额外卡组怪兽
function c44139064.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动代价：检查本回合是否未特殊召唤过融合怪兽以外的额外卡组怪兽，并注册本回合不能特殊召唤融合怪兽以外的额外卡组怪兽的限制
function c44139064.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查玩家本回合是否未从额外卡组特殊召唤过融合怪兽以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(44139064,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从卡组把1张「机人」卡加入手卡。②：自己的「机人」怪兽进行战斗的伤害计算时，从卡组把1只「机人」怪兽送去墓地才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44139064.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能从额外卡组特殊召唤融合怪兽以外的怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：选择卡组中可以加入手牌的「机人」卡片
function c44139064.thfilter(c)
	return c:IsSetCard(0x16) and c:IsAbleToHand()
end
-- 效果①的对象与条件检查：检测场上是否存在可破坏的卡（除这张卡以外）以及卡组是否存在可检索的「机人」卡
function c44139064.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=e:GetHandler() end
	-- 在chk为0时，检查场上是否存在至少1张自己场上除这张卡以外的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 且卡组中存在至少1张可检索的「机人」卡
		and Duel.IsExistingMatchingCard(c44139064.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张除这张卡以外的卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置效果处理信息：破坏选中的对象卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：从卡组把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：破坏作为对象的卡，成功破坏时将卡组中的1张「机人」卡加入手牌并确认
function c44139064.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若作为对象的卡片仍在场，则将其破坏，且在成功破坏后执行检索处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「机人」卡
		local g=Duel.SelectMatchingCard(tp,c44139064.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「机人」卡加入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方展示并确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果②的发动条件：进行战斗的自己怪兽必须是「机人」怪兽
function c44139064.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		-- 若攻击怪兽不由自己控制，则获取作为攻击目标的怪兽（即自己被攻击的怪兽）
		a=Duel.GetAttackTarget()
	end
	return a and a:IsSetCard(0x16)
end
-- 过滤函数：检索卡组中可送去墓地的「机人」怪兽
function c44139064.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价：从卡组把1只「机人」怪兽送去墓地，并注册本回合只能特殊召唤融合怪兽的限制
function c44139064.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查卡组中是否存在可送去墓地的「机人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44139064.atkfilter,tp,LOCATION_DECK,0,1,nil)
		-- 且本回合玩家没有特殊召唤过融合怪兽以外的额外卡组怪兽
		and Duel.GetCustomActivityCount(44139064,tp,ACTIVITY_SPSUMMON)==0 end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只「机人」怪兽
	local g=Duel.SelectMatchingCard(tp,c44139064.atkfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的「机人」怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。②：那只进行战斗的自己怪兽只在那次伤害计算时原本攻击力和原本守备力交换。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44139064.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能从额外卡组特殊召唤融合怪兽以外的怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的对象处理：将正在战斗的自己怪兽作为效果的对象
function c44139064.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		-- 若攻击怪兽不是自己控制的，则获取攻击目标的怪兽
		a=Duel.GetAttackTarget()
	end
	-- 将此战斗怪兽设为当前连锁的目标卡片
	Duel.SetTargetCard(a)
end
-- 效果②的效果处理：将正在战斗的自己「机人」怪兽的原本攻击力与原本守备力交换
function c44139064.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=tg:GetFirst()
	if tc:IsRelateToBattle() and tc:IsControler(tp) then
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 那只进行战斗的自己怪兽只在那次伤害计算时原本攻击力和原本守备力交换。
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
