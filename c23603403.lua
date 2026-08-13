--RR－サテライト・キャノン・ファルコン
-- 效果：
-- 鸟兽族8星怪兽×2
-- ①：这张卡用「急袭猛禽」怪兽为素材作超量召唤成功的场合才能发动。对方场上的魔法·陷阱卡全部破坏。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降自己墓地的「急袭猛禽」怪兽数量×800。这个效果在对方回合也能发动。
function c23603403.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只鸟兽族8星怪兽为素材进行超量召唤。
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
	-- 这张卡用「急袭猛禽」怪兽为素材作超量召唤成功的场合
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
	-- 设定②效果的发动条件：只能在伤害步骤中伤害计算前发动，伤害计算后不能发动。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c23603403.atkcost)
	e3:SetTarget(c23603403.atktg)
	e3:SetOperation(c23603403.atkop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡是超量召唤成功，且通过素材检查标记确认素材中含有「急袭猛禽」怪兽。
function c23603403.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 过滤函数：筛选对方场上的魔法·陷阱卡（不包含怪兽卡），用于确定破坏对象。
function c23603403.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动时处理：确认对方场上有魔法·陷阱卡可破坏，将全部魔法·陷阱卡登记为破坏对象，并设置连锁限制禁止对方对应发动效果。
function c23603403.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：对方场上是否存在至少1张魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c23603403.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部魔法·陷阱卡，作为预定破坏的卡集合。
	local g=Duel.GetMatchingGroup(c23603403.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 将本次效果要破坏的卡组和数量写入连锁信息，便于其他卡响应时判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置本次连锁的连锁限制，使对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	Duel.SetChainLimit(c23603403.chainlm)
end
-- ①效果处理：再次获取对方场上存在的魔法·陷阱卡，并将其全部破坏。
function c23603403.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取对方场上的全部魔法·陷阱卡，确保破坏的是实际仍在场上的卡。
	local g=Duel.GetMatchingGroup(c23603403.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因将这些魔法·陷阱卡全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 连锁限制条件：只允许本效果发动者自己连锁后续效果，即对方不能连锁任何效果，因此对方不能对应发动魔法·陷阱·怪兽效果。
function c23603403.chainlm(e,rp,tp)
	return tp==rp
end
-- 素材检查：判断超量召唤所用的素材中是否有「急袭猛禽」怪兽，若有则给①效果设置标记1，否则标记0。
function c23603403.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xba) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ②效果的发动代价：取除这张卡的1个超量素材。
function c23603403.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：筛选自己墓地的「急袭猛禽」怪兽卡，用于计算攻击力下降数值。
function c23603403.atkfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件与对象选择：自己墓地存在「急袭猛禽」怪兽且对方场上有表侧表示怪兽；选择对方场上1只表侧表示怪兽为对象。
function c23603403.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 判定发动条件：自己墓地是否存在至少1只「急袭猛禽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23603403.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 同时还需要存在可以成为对象的对方场上的表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示文本“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽，并将其作为本效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：取得对象怪兽，若其仍表侧表示且与效果有关，则根据自己墓地「急袭猛禽」怪兽数量，使其攻击力下降该数量×800。
function c23603403.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时确定的对方场上那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 统计自己墓地的「急袭猛禽」怪兽数量，作为攻击力下降的计算参数。
		local ct=Duel.GetMatchingGroupCount(c23603403.atkfilter,tp,LOCATION_GRAVE,0,nil)
		-- 那只怪兽的攻击力下降自己墓地的「急袭猛禽」怪兽数量×800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*-800)
		tc:RegisterEffect(e1)
	end
end
