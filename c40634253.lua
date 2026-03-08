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
-- 检索满足条件的机械族·暗属性怪兽
function c40634253.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 判断是否满足效果发动条件
function c40634253.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c40634253.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在满足条件的卡
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的自己场上的怪兽
	local g1=Duel.SelectTarget(tp,c40634253.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的对方场上的卡
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 处理效果的发动
function c40634253.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将对象卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 判断是否满足效果发动条件
function c40634253.damcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(1-tp) and tc:IsLocation(LOCATION_GRAVE) and tc:GetTextAttack()>0
		and bc:IsControler(tp) and bc:GetOriginalAttribute()==ATTRIBUTE_DARK and bc:GetOriginalRace()==RACE_MACHINE and bc:IsType(TYPE_MONSTER)
end
-- 检索满足条件的被破坏怪兽
function c40634253.damfilter2(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_DESTROY) and c:IsLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(1-tp) and c:GetTextAttack()>0
end
-- 判断是否满足效果发动条件
function c40634253.damcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	-- 获取连锁的控制者和位置
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return tgp==tp and loc==LOCATION_MZONE
		and rc:GetOriginalAttribute()==ATTRIBUTE_DARK and rc:GetOriginalRace()==RACE_MACHINE
		and eg:IsExists(c40634253.damfilter2,1,nil,tp)
end
-- 设置效果处理信息
function c40634253.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 处理效果的发动
function c40634253.damop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 给与对方伤害
	Duel.Damage(1-tp,math.floor(tc:GetTextAttack()/2),REASON_EFFECT)
end
-- 处理效果的发动
function c40634253.damop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c40634253.damfilter2,nil,tp)
	local tc=nil
	if #g>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	elseif #g==1 then
		tc=g:GetFirst()
	end
	if tc then
		-- 给与对方伤害
		Duel.Damage(1-tp,math.floor(tc:GetTextAttack()/2),REASON_EFFECT)
	end
end
