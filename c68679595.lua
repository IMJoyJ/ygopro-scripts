--獣装合体 ライオ・ホープレイ
-- 效果：
-- 5星怪兽×3
-- 这个卡名在规则上当作「混沌No.39 希望皇 霍普雷」使用。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动（这个效果的发动和效果不会被无效化）。从卡组·额外卡组选1只「异热同心武器」怪兽当作那个效果的装备魔法卡使用给这张卡装备。
-- ②：双方回合1次，这张卡有「异热同心武器」怪兽卡装备的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效，那个攻击力变成一半。
function c68679595.initial_effect(c)
	-- 添加XYZ召唤手续：5星怪兽×3。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动（这个效果的发动和效果不会被无效化）。从卡组·额外卡组选1只「异热同心武器」怪兽当作那个效果的装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68679595,0))  --"装备异热同心武器"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCountLimit(1)
	e1:SetCost(c68679595.eqcost)
	e1:SetTarget(c68679595.eqtg)
	e1:SetOperation(c68679595.eqop)
	c:RegisterEffect(e1)
	-- ②：双方回合1次，这张卡有「异热同心武器」怪兽卡装备的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效，那个攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68679595,1))  --"对方怪兽的效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c68679595.discon)
	e2:SetTarget(c68679595.distg)
	e2:SetOperation(c68679595.disop)
	c:RegisterEffect(e2)
end
-- 设置该卡在规则上视为「No.39」怪兽（用于支持相关卡片的判定）。
aux.xyz_number[68679595]=39
-- 设置「混沌No.39 希望皇 霍普雷」在规则上视为「No.39」怪兽（用于支持相关卡片的判定）。
aux.xyz_number[56840427]=39
-- 效果①的代价处理：取除这张卡的1个超量素材。
function c68679595.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的装备卡过滤：检索卡组或额外卡组中可装备的「异热同心武器」怪兽。
function c68679595.eqfilter(c,tp)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c.zw_equip_monster and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 效果①的发动准备与合法性检查。
function c68679595.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或额外卡组是否存在至少1只满足条件的「异热同心武器」怪兽。
		and Duel.IsExistingMatchingCard(c68679595.eqfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果①的效果处理：从卡组或额外卡组选择1只「异热同心武器」怪兽装备给这张卡。
function c68679595.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己场上没有可用的魔法与陷阱区域空格，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 提示玩家选择要装备的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组或额外卡组选择1只满足条件的「异热同心武器」怪兽。
		local g=Duel.SelectMatchingCard(tp,c68679595.eqfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if not tc then return end
		tc.zw_equip_monster(tc,tp,c)
	end
end
-- 过滤出表侧表示且原本是怪兽卡的「异热同心武器」卡。
function c68679595.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107e) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 效果②的发动条件判定：检查自身是否有「异热同心武器」怪兽卡装备，且当前不处于伤害计算后。
function c68679595.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()
	-- 判定装备卡中是否存在「异热同心武器」怪兽卡，且当前时点非伤害计算后。
	return g:IsExists(c68679595.cfilter,1,nil) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果②的对象选择与合法性检查。
function c68679595.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定指向的对象是否为对方场上表侧表示且未被无效的效果怪兽。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只可以成为对象的、未被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效效果的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只未被无效的效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明该效果包含“使效果无效”的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的效果处理：使作为对象的怪兽效果无效，且攻击力变成一半。
function c68679595.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local atk=tc:GetAttack()
		-- 那只怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 立即刷新场上卡片的无效状态，确保后续攻击力减半处理基于正确的状态。
		Duel.AdjustInstantly()
		-- 那个攻击力变成一半。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e3)
	end
end
