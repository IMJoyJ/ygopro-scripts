--CNo.103 神葬零嬢ラグナ・インフィニティ
-- 效果：
-- 5星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，那只怪兽除外。这个效果在对方回合也能发动。
-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。这个效果在自己墓地有「No.103 神葬零娘 暮零」存在的场合才能发动和处理。
function c20785975.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用任意3只5星怪兽叠放作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，那只怪兽除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20785975,0))  --"除外伤害"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c20785975.cost)
	e1:SetTarget(c20785975.target)
	e1:SetOperation(c20785975.operation)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。这个效果在自己墓地有「No.103 神葬零娘 暮零」存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20785975,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c20785975.spcon)
	e2:SetTarget(c20785975.sptg)
	e2:SetOperation(c20785975.spop)
	c:RegisterEffect(e2)
end
-- 将这张卡登记为编号103的XYZ怪兽，用于相关No.编号规则判定。
aux.xyz_number[20785975]=103
-- 效果①的发动代价：发动时检查能否取除这张卡的1个超量素材，实际发动时取除1个超量素材作为代价。
function c20785975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择条件：对方场上的表侧表示怪兽，其当前攻击力与原本攻击力不同，并且可以被除外。
function c20785975.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack()) and c:IsAbleToRemove()
end
-- 效果①发动时的目标选择：从对方场上选择1只符合条件的表侧表示怪兽作为对象，计算其当前攻击力与原本攻击力的差值绝对值，并分别设置除外对象和伤害数值的操作信息。
function c20785975.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c20785975.filter(chkc) end
	-- 效果发动时检查对方场上是否存在至少1只满足条件的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20785975.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要除外的卡”的选择提示信息，引导玩家选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方场上选择1只符合条件的怪兽作为效果对象，并自动将所选卡与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,c20785975.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local atk=math.abs(tc:GetAttack()-tc:GetBaseAttack())
	-- 设置操作信息：本次效果将除外选择的对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本次效果将对对方造成atk点伤害，atk为对象怪兽当前攻击力与原本攻击力的差值的绝对值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,atk)
end
-- 效果①的结算处理：取得对象怪兽，计算差值伤害；若对象仍与此效果有关且为表侧表示，则给对方造成伤害，伤害成功后将该对象怪兽除外。
function c20785975.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local atk=math.abs(tc:GetAttack()-tc:GetBaseAttack())
	-- 判定对象怪兽仍与此效果存在关联、仍表侧表示，并给对方造成atk点伤害；实际造成伤害（返回值非0）时才继续执行除外。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
		-- 将对象怪兽以表侧表示除外，原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被破坏并送去墓地，且破坏前在场上拥有超量素材，同时自己墓地存在「No.103 神葬零娘 暮零」。
function c20785975.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousOverlayCountOnField()>0
		-- 检查自己墓地存在卡号94380860的「No.103 神葬零娘 暮零」，这是效果②能发动和处理的前置条件。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,94380860)
end
-- 效果②的发动目标：检查自己场上有可用的特殊召唤区域，且这张卡可以被特殊召唤。
function c20785975.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将把这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的结算处理：若自己墓地仍有「No.103 神葬零娘 暮零」，且这张卡仍与此效果存在关联，则将这张卡特殊召唤。
function c20785975.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认墓地存在「No.103 神葬零娘 暮零」，若不存在则结束处理。
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,94380860) then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
