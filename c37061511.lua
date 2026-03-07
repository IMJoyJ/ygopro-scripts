--ウォーターリヴァイアサン＠イグニスター
-- 效果：
-- 「“艾”之仪式」降临。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。对方场上的攻击力2300以下的怪兽全部回到持有者手卡。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动。自己墓地的连接怪兽全部回到额外卡组，作为对象的怪兽的攻击力变成0。
-- ③：这张卡和对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力只在那次伤害计算时变成一半。
function c37061511.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。对方场上的攻击力2300以下的怪兽全部回到持有者手卡。
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
	-- ②：以对方场上1只表侧表示怪兽为对象才能发动。自己墓地的连接怪兽全部回到额外卡组，作为对象的怪兽的攻击力变成0。
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
	-- ③：这张卡和对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力只在那次伤害计算时变成一半。
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
-- 效果作用：判断此卡是否为仪式召唤成功
function c37061511.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果作用：过滤满足条件的怪兽（表侧表示、攻击力2300以下、可送回手卡）
function c37061511.thfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(2300) and c:IsAbleToHand()
end
-- 效果作用：设置连锁处理信息，确定将要送回手卡的怪兽组
function c37061511.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足发动条件（对方场上是否存在攻击力2300以下的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c37061511.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取满足条件的对方怪兽组
	local g=Duel.GetMatchingGroup(c37061511.thfilter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置连锁处理信息，确定将要送回手卡的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果作用：执行将怪兽送回手卡的操作
function c37061511.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取满足条件的对方怪兽组
	local g=Duel.GetMatchingGroup(c37061511.thfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 效果作用：将怪兽送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 效果作用：过滤满足条件的连接怪兽（可送回额外卡组）
function c37061511.tefilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 效果作用：设置连锁处理信息，确定将要送回额外卡组的连接怪兽组
function c37061511.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果作用：判断目标是否为对方场上的表侧表示怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 效果作用：检查是否满足发动条件（自己墓地是否存在连接怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c37061511.tefilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 效果作用：检查是否满足发动条件（对方场上是否存在表侧表示怪兽）
		and Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择对方场上的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择对方场上的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	-- 效果作用：获取满足条件的连接怪兽组
	local g=Duel.GetMatchingGroup(c37061511.tefilter,tp,LOCATION_GRAVE,0,nil)
	-- 效果作用：设置连锁处理信息，确定将要送回额外卡组的连接怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,g:GetCount(),0,0)
end
-- 效果作用：执行将连接怪兽送回额外卡组并使对象怪兽攻击力变为0的操作
function c37061511.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：获取满足条件的连接怪兽组
	local g=Duel.GetMatchingGroup(c37061511.tefilter,tp,LOCATION_GRAVE,0,nil)
	-- 效果作用：检查是否因王家长眠之谷而无效此效果
	if aux.NecroValleyNegateCheck(g) then return end
	-- 效果作用：检查是否满足发动条件（连接怪兽是否成功送回额外卡组）
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果作用：设置对象怪兽的攻击力为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 效果作用：判断是否满足发动条件（此卡是否在战斗阶段中且对方有表侧表示怪兽）
function c37061511.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 效果作用：判断是否满足发动条件（对方有表侧表示怪兽且为对方控制）
	return bc and aux.nzatk(bc) and bc:IsControler(1-tp)
end
-- 效果作用：设置发动条件（此卡在战斗阶段中且未发动过此效果）
function c37061511.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(37061511)==0 end
	c:RegisterFlagEffect(37061511,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果作用：执行将对方怪兽攻击力减半的操作
function c37061511.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		-- 效果作用：设置对象怪兽的攻击力为原攻击力的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(bc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		bc:RegisterEffect(e1)
	end
end
