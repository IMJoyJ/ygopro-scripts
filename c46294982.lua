--ヘクサ・トルーデ
-- 效果：
-- ①：场地区域有「急流山的金宫」存在的场合，这张卡可以不用解放作召唤。
-- ②：1回合1次，场地区域有「急流山的金宫」存在的场合，以场上1张卡为对象才能发动。那张卡破坏，这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡战斗破坏对方怪兽时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升400。
function c46294982.initial_effect(c)
	-- 记录该卡具有「急流山的金宫」这张卡的卡片密码
	aux.AddCodeList(c,72283691)
	-- ①：场地区域有「急流山的金宫」存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46294982,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c46294982.ntcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，场地区域有「急流山的金宫」存在的场合，以场上1张卡为对象才能发动。那张卡破坏，这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46294982,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c46294982.descon)
	e2:SetTarget(c46294982.destg)
	e2:SetOperation(c46294982.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46294982,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果触发条件为该怪兽与对方怪兽战斗且被战斗破坏
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c46294982.atktg)
	e3:SetOperation(c46294982.atkop)
	c:RegisterEffect(e3)
end
-- 判断召唤条件是否满足：不需解放、等级不低于5、场地区域存在「急流山的金宫」、场上主怪兽区域有空位
function c46294982.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤条件是否满足：不需解放、等级不低于5、场地区域存在「急流山的金宫」
	return minc==0 and c:IsLevelAbove(5) and Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE)
		-- 判断召唤条件是否满足：场上主怪兽区域有空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断效果发动条件是否满足：场地区域存在「急流山的金宫」
function c46294982.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果发动条件是否满足：场地区域存在「急流山的金宫」
	return Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE)
end
-- 设置效果目标选择逻辑：选择场上任意一张卡作为破坏对象
function c46294982.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local c=e:GetHandler()
	-- 设置效果目标选择逻辑：选择场上任意一张卡作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果处理：若目标卡存在且被成功破坏，则使自身在本回合可额外攻击一次
function c46294982.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上、是否被成功破坏、自身是否仍在场
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 设置自身在本回合可额外攻击一次的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 设置效果目标选择逻辑：选择自己场上一只表侧表示的怪兽
function c46294982.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 设置效果目标选择逻辑：选择自己场上一只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要提升攻击力的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上一只表侧表示的怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果处理：使目标怪兽攻击力上升400
function c46294982.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 设置目标怪兽攻击力上升400的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
