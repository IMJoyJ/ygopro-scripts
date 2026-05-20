--SPYRAL GEAR－エクストラアームズ
-- 效果：
-- 「秘旋谍-花公子」才能装备。
-- ①：装备怪兽的攻击力上升1000。
-- ②：装备怪兽战斗破坏对方怪兽的场合才能发动。选对方场上1张卡，那张卡和破坏的怪兽除外。
-- ③：场上的表侧表示的这张卡被破坏送去墓地时，以自己墓地1只「秘旋谍-花公子」为对象才能发动。那只怪兽特殊召唤。
function c73828446.initial_effect(c)
	-- 「秘旋谍-花公子」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c73828446.target)
	e1:SetOperation(c73828446.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 「秘旋谍-花公子」才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c73828446.eqlimit)
	c:RegisterEffect(e3)
	-- ②：装备怪兽战斗破坏对方怪兽的场合才能发动。选对方场上1张卡，那张卡和破坏的怪兽除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(73828446,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(c73828446.rmcon)
	e4:SetTarget(c73828446.rmtg)
	e4:SetOperation(c73828446.rmop)
	c:RegisterEffect(e4)
	-- ③：场上的表侧表示的这张卡被破坏送去墓地时，以自己墓地1只「秘旋谍-花公子」为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(aux.Stringid(73828446,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c73828446.spcon)
	e5:SetTarget(c73828446.sptg)
	e5:SetOperation(c73828446.spop)
	c:RegisterEffect(e5)
end
-- 装备限制：只能装备给「秘旋谍-花公子」
function c73828446.eqlimit(e,c)
	return c:IsCode(41091257)
end
-- 过滤条件：场上表侧表示的「秘旋谍-花公子」
function c73828446.filter(c)
	return c:IsFaceup() and c:IsCode(41091257)
end
-- 装备魔法卡发动时的效果处理（选择装备对象）
function c73828446.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c73828446.filter(chkc) end
	-- 检查场上是否存在可以装备的「秘旋谍-花公子」
	if chk==0 then return Duel.IsExistingTarget(c73828446.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只「秘旋谍-花公子」作为装备对象
	Duel.SelectTarget(tp,c73828446.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理（将此卡装备给目标怪兽）
function c73828446.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果发动条件：装备怪兽战斗破坏了怪兽
function c73828446.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 除外效果的发动准备与目标选择
function c73828446.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=eg:GetFirst():GetBattleTarget()
	e:SetLabelObject(bc)
	if chk==0 then return bc:IsAbleToRemove()
		-- 检查对方场上是否存在至少1张可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,bc) end
	-- 设置操作信息：将战斗破坏的怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,bc:GetControler(),LOCATION_GRAVE)
end
-- 除外效果的实际处理
function c73828446.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsAbleToRemove() then
		-- 获取对方场上可以除外的卡片组（排除已被战斗破坏的怪兽）
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,bc)
		if g:GetCount()==0 then return end
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 手动显示被选择除外的卡片的动画效果
		Duel.HintSelection(sg)
		sg:AddCard(bc)
		-- 将选中的卡和战斗破坏的怪兽一起除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果发动条件：场上表侧表示的这张卡被破坏送去墓地
function c73828446.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤条件：墓地中的「秘旋谍-花公子」且可以特殊召唤
function c73828446.spfilter(c,e,tp)
	return c:IsCode(41091257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标选择
function c73828446.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73828446.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「秘旋谍-花公子」
		and Duel.IsExistingTarget(c73828446.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「秘旋谍-花公子」作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c73828446.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理
function c73828446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
