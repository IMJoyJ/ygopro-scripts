--BM－4ボムスパイダー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以自己场上1只机械族·暗属性怪兽和对方场上1张表侧表示的卡为对象才能发动。那些卡破坏。
-- ②：自己场上的原本的种族·属性是机械族·暗属性的怪兽用战斗或者自身的效果破坏对方场上的怪兽送去墓地的场合才能发动。给与对方那1只破坏送去墓地的怪兽的原本攻击力一半数值的伤害。
function c40634253.initial_effect(c)
	-- ①：1回合1次，以自己场上1只机械族·暗属性怪兽和对方场上1张表侧表示的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40634253,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c40634253.destg)
	e1:SetOperation(c40634253.desop)
	c:RegisterEffect(e1)
	-- ②：自己场上的原本的种族·属性是机械族·暗属性的怪兽用战斗或者自身的效果破坏对方场上的怪兽送去墓地的场合才能发动。给与对方那1只破坏送去墓地的怪兽的原本攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40634253,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40634253)
	e2:SetCondition(c40634253.damcon1)
	e2:SetTarget(c40634253.damtg)
	e2:SetOperation(c40634253.damop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c40634253.damcon2)
	e3:SetOperation(c40634253.damop2)
	c:RegisterEffect(e3)
end
-- 筛选自己场上符合①效果对象条件的怪兽：表侧表示、机械族、暗属性。
function c40634253.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ①效果的目标设定函数：若系统传入指定对象chkc则直接拒绝；在发动条件检查阶段（chk==0）确认自己场上存在符合条件的机械族暗属性表侧怪兽，且对方场上存在表侧表示的卡，两项同时满足才可发动。
function c40634253.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- chk==0时，检查自己场上是否存在至少1只可选的机械族·暗属性表侧怪兽（作为其中一个对象）。
	if chk==0 then return Duel.IsExistingTarget(c40634253.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在至少1张表侧表示的卡，可作为另一个对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 发动时向玩家弹出选择提示，提示语为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只符合条件的机械族·暗属性表侧怪兽，并设为效果的取对象。
	local g1=Duel.SelectTarget(tp,c40634253.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 发动时向玩家弹出选择提示，提示语为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张表侧表示的卡，并设为效果的取对象。
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将已选择的两张对象卡合并后的组登记为破坏操作信息，声明本效果将破坏2张卡，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 处理破坏：从当前连锁中取出取对象卡组，过滤出仍与效果关联的卡，若存在则将这些卡全部以效果破坏。
function c40634253.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的对象卡组，即发动时选择的自方怪兽和对方场上的那张卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将过滤后仍与效果关联的对象卡以效果破坏送入墓地。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果战斗破坏分支的触发条件：被战斗破坏并送去墓地的对方怪兽原本攻击力大于0，且与其战斗的对象是自己场上原本种族为机械、原本属性为暗的怪兽。
function c40634253.damcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(1-tp) and tc:IsLocation(LOCATION_GRAVE) and tc:GetTextAttack()>0
		and bc:IsControler(tp) and bc:GetOriginalAttribute()==ATTRIBUTE_DARK and bc:GetOriginalRace()==RACE_MACHINE and bc:IsType(TYPE_MONSTER)
end
-- 筛选因自身效果被破坏并送去墓地的对方怪兽：因效果且因破坏而送去墓地、原控制者为对方、是怪兽且原本攻击力大于0。
function c40634253.damfilter2(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_DESTROY) and c:IsLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(1-tp) and c:GetTextAttack()>0
end
-- ②效果自身效果破坏分支的触发条件：触发原因来自自己场上（主要怪兽区）的机械族·暗属性怪兽的效果，且本次送去墓地的怪兽中有满足damfilter2的对方怪兽。
function c40634253.damcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	-- 从连锁信息中取出触发效果的控制者和发生位置，用于判断是否是己方场上怪兽的效果。
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return tgp==tp and loc==LOCATION_MZONE
		and rc:GetOriginalAttribute()==ATTRIBUTE_DARK and rc:GetOriginalRace()==RACE_MACHINE
		and eg:IsExists(c40634253.damfilter2,1,nil,tp)
end
-- 伤害效果的目标设定：发动时无需选择卡片，直接返回true，并设置伤害操作信息。
function c40634253.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记对对方造成伤害的操作信息，具体伤害数值在效果处理阶段计算。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- ②效果战斗破坏分支的伤害处理：以被战斗破坏的对方怪兽的原本攻击力一半数值，向对方造成伤害。
function c40634253.damop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 给予对方该怪兽原本攻击力一半数值的伤害。
	Duel.Damage(1-tp,math.floor(tc:GetTextAttack()/2),REASON_EFFECT)
end
-- ②效果自身效果破坏分支的伤害处理：筛选出满足条件的对方怪兽，若有多只则由玩家选择其中1只，然后给予对方其原本攻击力一半数值的伤害。
function c40634253.damop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c40634253.damfilter2,nil,tp)
	local tc=nil
	if #g>1 then
		-- 当存在多个符合条件的怪兽时，提示玩家选择要计算伤害的那只怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	elseif #g==1 then
		tc=g:GetFirst()
	end
	if tc then
		-- 给予对方所选择的怪兽原本攻击力一半数值的伤害。
		Duel.Damage(1-tp,math.floor(tc:GetTextAttack()/2),REASON_EFFECT)
	end
end
