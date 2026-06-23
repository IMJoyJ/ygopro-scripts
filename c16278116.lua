--竜の束縛
-- 效果：
-- 以自己场上1只攻击力·守备力是2500以下的龙族怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把作为对象的怪兽的原本攻击力以下的怪兽特殊召唤。
-- ②：作为对象的怪兽从场上离开时这张卡破坏。
function c16278116.initial_effect(c)
	-- 以自己场上1只攻击力·守备力是2500以下的龙族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c16278116.target)
	c:RegisterEffect(e1)
	-- （记录作为对象的怪兽，供后续效果参照）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(c16278116.tgcon)
	e2:SetOperation(c16278116.tgop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把作为对象的怪兽的原本攻击力以下的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c16278116.splimit)
	c:RegisterEffect(e3)
	-- ②：作为对象的怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c16278116.descon)
	e4:SetOperation(c16278116.desop)
	c:RegisterEffect(e4)
end
-- 定义筛选条件：检查怪兽是否为表侧表示的龙族，且攻击力与守备力均在2500以下
function c16278116.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttackBelow(2500) and c:IsDefenseBelow(2500)
end
-- 定义发动时的取对象目标函数：选择符合条件的怪兽作为效果对象
function c16278116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16278116.filter(chkc) end
	-- 检查发动条件：自己场上是否存在符合条件的表侧表示怪兽（龙族、攻守2500以下）
	if chk==0 then return Duel.IsExistingTarget(c16278116.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己的怪兽区选择1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c16278116.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 检查当前处理完毕的连锁是否是这张卡的发动（e1）
function c16278116.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 在发动处理完毕时，将选择的怪兽设为这张卡的关联目标（CardTarget），确立"作为对象的怪兽"
function c16278116.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象（目标卡片组中的第一张）
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc:IsFaceup() and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
	end
end
-- 定义特殊召唤限制：禁止特殊召唤攻击力不高于作为对象的怪兽原本攻击力的怪兽
function c16278116.splimit(e,c,tp,sumtp,sumpos)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and c:IsAttackBelow(tc:GetBaseAttack())
end
-- 检查破坏条件：作为对象的怪兽是否从场上离开，且这张卡未被预定破坏
function c16278116.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 执行这张卡的自我破坏处理
function c16278116.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡破坏（自我破坏）
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
