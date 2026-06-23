--RR－サテライト・キャノン・ファルコン
-- 效果：
-- 鸟兽族8星怪兽×2
-- ①：这张卡用「急袭猛禽」怪兽为素材作超量召唤成功的场合才能发动。对方场上的魔法·陷阱卡全部破坏。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降自己墓地的「急袭猛禽」怪兽数量×800。这个效果在对方回合也能发动。
function c23603403.initial_effect(c)
	-- 添加超量召唤手续，要求使用满足鸟兽族条件的8星怪兽作为素材进行超量召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),8,2)
	c:EnableReviveLimit()
	-- ①：这张卡用「急袭猛禽」怪兽为素材作超量召唤成功的场合才能发动。对方场上的魔法·陷阱卡全部破坏。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23603403,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23603403.descon)
	e1:SetTarget(c23603403.destg)
	e1:SetOperation(c23603403.desop)
	c:RegisterEffect(e1)
	-- ①：这张卡用「急袭猛禽」怪兽为素材作超量召唤成功的场合才能发动。对方场上的魔法·陷阱卡全部破坏。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c23603403.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降自己墓地的「急袭猛禽」怪兽数量×800。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23603403,1))  --"攻击力下降"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件为伤害步骤中，防止在伤害计算后发动
	e3:SetCondition(aux.dscon)
	e3:SetCost(c23603403.atkcost)
	e3:SetTarget(c23603403.atktg)
	e3:SetOperation(c23603403.atkop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为超量召唤且满足条件（由素材是否包含急袭猛禽怪兽决定）
function c23603403.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 过滤函数，用于筛选魔法·陷阱卡
function c23603403.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标为对方场上的魔法·陷阱卡，并设定连锁限制
function c23603403.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23603403.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c23603403.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，表示将要破坏这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁限制，防止对方连锁此效果
	Duel.SetChainLimit(c23603403.chainlm)
end
-- 执行破坏操作，将对方场上的魔法·陷阱卡全部破坏
function c23603403.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c23603403.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 实际执行破坏操作
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 连锁限制函数，仅允许发动玩家连锁
function c23603403.chainlm(e,rp,tp)
	return tp==rp
end
-- 检查此卡的超量素材中是否包含急袭猛禽怪兽，并设置标签以供后续判断
function c23603403.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xba) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 支付效果成本，从自身取除1个超量素材
function c23603403.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选墓地中的急袭猛禽怪兽
function c23603403.atkfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- 设置效果目标为对方场上的1只表侧表示怪兽，并检查是否有足够的墓地急袭猛禽怪兽
function c23603403.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查墓地是否存在急袭猛禽怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23603403.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 执行效果，使目标怪兽攻击力下降
function c23603403.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 统计墓地中的急袭猛禽怪兽数量
		local ct=Duel.GetMatchingGroupCount(c23603403.atkfilter,tp,LOCATION_GRAVE,0,nil)
		-- 创建攻击力下降效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*-800)
		tc:RegisterEffect(e1)
	end
end
