--ウォーターリヴァイアサン＠イグニスター
-- 效果：
-- 「“艾”之仪式」降临。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。对方场上的攻击力2300以下的怪兽全部回到持有者手卡。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动。自己墓地的连接怪兽全部回到额外卡组，作为对象的怪兽的攻击力变成0。
-- ③：这张卡和对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力只在那次伤害计算时变成一半。
function c37061511.initial_effect(c)
	-- 将卡片「“艾”之仪式」（85327820）加入到此卡的关联卡片代码列表中
	aux.AddCodeList(c,85327820)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。对方场上的攻击力2300以下的怪兽全部回到持有者手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37061511,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37061511.thcon)
	e1:SetTarget(c37061511.thtg)
	e1:SetOperation(c37061511.thop)
	c:RegisterEffect(e1)
	-- ②：以对方场上1只表侧表示怪兽为对象才能发动。自己墓地的连接怪兽全部回到额外卡组，作为对象的怪兽的攻击力变成0
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37061511,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37061511)
	e2:SetTarget(c37061511.tetg)
	e2:SetOperation(c37061511.teop)
	c:RegisterEffect(e2)
	-- ③：这张卡和对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力只在那次伤害计算时变成一半
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37061511,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c37061511.atkcon)
	e3:SetCost(c37061511.atkcost)
	e3:SetOperation(c37061511.atkop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否是通过仪式召唤特殊召唤成功，以确定是否满足效果①的发动条件
function c37061511.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤对方场上表侧表示且攻击力在2300以下、可以回到手牌的怪兽
function c37061511.thfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(2300) and c:IsAbleToHand()
end
-- 定义效果①的靶向/可行性检查逻辑，以及设置弹回手牌操作信息
function c37061511.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力在2300以下的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37061511.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示且攻击力在2300以下的怪兽
	local g=Duel.GetMatchingGroup(c37061511.thfilter,tp,0,LOCATION_MZONE,nil)
	-- 向系统声明此效果的操作信息为“将符合条件的怪兽全部回到持有者手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义效果①的具体处理逻辑：将对方场上符合条件的怪兽送回手牌
function c37061511.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c37061511.thfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤墓地中可以回到额外卡组的连接怪兽
function c37061511.tefilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 定义效果②的对象确认和可行性检查逻辑
function c37061511.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果处理前进行对象合法性验证：确认目标怪兽是否位于对方场上，且为表侧表示攻击力大于0的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 判断自己墓地中是否存在至少1只连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37061511.tefilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且对方场上存在至少1只表侧表示且攻击力大于0的怪兽
		and Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示且攻击力大于0的怪兽作为效果的对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	-- 获取自己墓地的全部连接怪兽
	local g=Duel.GetMatchingGroup(c37061511.tefilter,tp,LOCATION_GRAVE,0,nil)
	-- 向系统声明此效果的操作信息为“将墓地的这些连接怪兽全部回到额外卡组”
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,g:GetCount(),0,0)
end
-- 定义效果②的具体处理逻辑：将自己墓地的连接怪兽全部回到额外卡组，并将选中的怪兽攻击力变成0
function c37061511.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己墓地的全部连接怪兽
	local g=Duel.GetMatchingGroup(c37061511.tefilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查是否受到「王家长眠之谷」的影响，若受到影响则无效效果的操作
	if aux.NecroValleyNegateCheck(g) then return end
	-- 若墓地中存在至少1只连接怪兽，将其送回额外卡组并洗卡组
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽的攻击力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 检查战斗发生的双方，以判断是否满足效果③的发动条件：此卡与对方攻击力大于0的怪兽进行战斗
function c37061511.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断当前是否存在战斗的目标怪兽，且该怪兽属于对方且攻击力大于0
	return bc and aux.nzatk(bc) and bc:IsControler(1-tp)
end
-- 定义效果③的发动代价：注册标志以限制该效果在这次伤害计算中只能发动1次
function c37061511.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(37061511)==0 end
	c:RegisterFlagEffect(37061511,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 定义效果③的具体处理逻辑：使进行战斗的对方怪兽攻击力在伤害计算时变成一半
function c37061511.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力只在那次伤害计算时变成一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(bc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		bc:RegisterEffect(e1)
	end
end
