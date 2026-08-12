--RR－ライジング・リベリオン・ファルコン
-- 效果：
-- 鸟兽族13星怪兽×5
-- ①：这张卡超量召唤的场合才能发动。对方场上的卡全部破坏。那之后，这张卡有「急袭猛禽」超量怪兽3种类以上在作为素材的场合，给与对方这个效果破坏的怪兽的原本攻击力合计数值的伤害。
-- ②：场上的这张卡不受其他卡的效果影响。
-- ③：1回合1次，把这张卡3个超量素材取除，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。直到结束阶段，这张卡得到和那只怪兽相同的效果。
local s,id,o=GetID()
-- 初始化函数，注册卡片的各项效果，包括XYZ召唤手续、不受其他卡效果影响的永续效果、超量召唤成功时破坏对方场上卡片并给予伤害的诱发效果，以及去除3个素材复制墓地「急袭猛禽」超量怪兽效果的起动效果
function s.initial_effect(c)
	-- 设置XYZ召唤手续：鸟兽族13星怪兽×5
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),13,5)
	c:EnableReviveLimit()
	-- ②：场上的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ①：这张卡超量召唤的场合才能发动。对方场上的卡全部破坏。那之后，这张卡有「急袭猛禽」超量怪兽3种类以上在作为素材的场合，给与对方这个效果破坏的怪兽的原本攻击力合计数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡3个超量素材取除，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。直到结束阶段，这张卡得到和那只怪兽相同的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"得到效果"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.copycost)
	e3:SetTarget(s.copytg)
	e3:SetOperation(s.copyop)
	c:RegisterEffect(e3)
end
-- 定义免疫效果的过滤函数，判定效果来源是否为其他卡片
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 判定发动条件是否为自身超量召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 估算伤害时的辅助过滤函数，获取场上怪兽的原本攻击力
function s.damval1(c)
	if c:GetLocation()~=LOCATION_MZONE then return end
	return math.max(0,c:GetTextAttack())
end
-- 实际计算伤害时的辅助过滤函数，获取从怪兽区域被破坏的怪兽的原本攻击力
function s.damval2(c)
	if c:GetPreviousLocation()~=LOCATION_MZONE then return end
	return math.max(0,c:GetTextAttack())
end
-- 破坏与伤害效果的发动准备，检查对方场上是否有卡，并注册破坏和伤害的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置破坏操作信息，包含要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	local atk=g:GetSum(s.damval1)
	-- 若预估伤害大于0，则设置伤害操作信息
	if atk>0 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) end
end
-- 过滤自身超量素材中「急袭猛禽」超量怪兽的条件函数
function s.xfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0xba)
end
-- 破坏与伤害效果的执行函数，破坏对方场上所有的卡，并判定自身是否有3种以上「急袭猛禽」超量怪兽作为素材，若是则给予对方被破坏怪兽原本攻击力合计数值的伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有的卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏对方场上的卡片，并判定是否有卡片被成功破坏以及自身是否仍在场
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e)
		and c:GetOverlayGroup():Filter(s.xfilter,nil):GetClassCount(Card.GetCode)>=3 then
		-- 获取本次操作中实际被破坏的卡片组
		local dg=Duel.GetOperatedGroup()
		local atk=dg:GetSum(s.damval2)
		if atk>0 then
			-- 中断当前效果处理，使后续的伤害处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 给与对方玩家被破坏怪兽原本攻击力合计数值的效果伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- 过滤自己墓地中「急袭猛禽」超量怪兽的条件函数
function s.filter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_XYZ)
end
-- 复制效果的发动代价，检查并去除3个超量素材，并为自身注册一回合一次的标识
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 and c:CheckRemoveOverlayCard(tp,3,REASON_COST) end
	c:RemoveOverlayCard(tp,3,3,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 复制效果的发动准备，选择自己墓地1只「急袭猛禽」超量怪兽作为效果的对象
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 判定自己墓地是否存在符合条件的「急袭猛禽」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择并锁定自己墓地1只「急袭猛禽」超量怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 复制效果的执行函数，使自身直到结束阶段得到作为对象的怪兽的相同效果
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的目标对象（即墓地的「急袭猛禽」超量怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
