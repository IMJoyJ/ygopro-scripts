--B・F－追撃のダート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「蜂军」怪兽战斗破坏原本持有者是对方的怪兽时，把这张卡从手卡丢弃才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
function c91283212.initial_effect(c)
	-- ①：自己的「蜂军」怪兽战斗破坏原本持有者是对方的怪兽时，把这张卡从手卡丢弃才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,91283212)
	e1:SetCondition(c91283212.damcon)
	e1:SetCost(c91283212.damcost)
	e1:SetTarget(c91283212.damtg)
	e1:SetOperation(c91283212.damop)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,91283213)
	e2:SetTarget(c91283212.target)
	e2:SetOperation(c91283212.operation)
	c:RegisterEffect(e2)
end
-- 判断是否满足自己的「蜂军」怪兽战斗破坏对方原本持有怪兽的发动条件
function c91283212.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return a:IsSetCard(0x12f) and d:IsStatus(STATUS_BATTLE_DESTROYED) and d:GetOwner()==1-tp
end
-- 丢弃手卡的这张卡作为发动的代价
function c91283212.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 设置给与对方伤害效果的对象与操作信息
function c91283212.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	local atk=d:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(atk)
	-- 设置连锁的操作信息为给与对方原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行给与对方原本攻击力数值伤害的效果处理
function c91283212.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤场上表侧表示且不是调整的昆虫族怪兽
function c91283212.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and not c:IsType(TYPE_TUNER)
end
-- 选择自己场上1只这张卡以外的表侧表示昆虫族怪兽作为对象
function c91283212.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c91283212.filter(chkc) and chkc~=e:GetHandler() end
	-- 判断自己场上是否存在除这张卡以外的、满足条件的昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c91283212.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只这张卡以外的表侧表示昆虫族怪兽作为效果对象
	Duel.SelectTarget(tp,c91283212.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 使目标怪兽当作调整使用，并限制本回合只能从额外卡组特殊召唤昆虫族怪兽
function c91283212.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
	-- 这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c91283212.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能从额外卡组特殊召唤昆虫族以外怪兽的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能从额外卡组特殊召唤昆虫族以外的怪兽
function c91283212.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
