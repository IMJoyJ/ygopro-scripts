--No.39 希望皇ビヨンド・ザ・ホープ
-- 效果：
-- 6星怪兽×2
-- 这个卡名在规则上也当作「希望皇 霍普」卡使用。
-- ①：这张卡超量召唤成功的场合发动。对方场上的全部怪兽的攻击力变成0。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只超量怪兽和自己墓地1只「希望皇 霍普」怪兽为对象才能发动。那只自己场上的超量怪兽除外，那只墓地的怪兽特殊召唤。那之后，自己回复1250基本分。这个效果在对方回合也能发动。
function c21521304.initial_effect(c)
	-- 为这张卡添加超量召唤手续：使用等级6的怪兽2只作为超量素材。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的场合发动。对方场上的全部怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21521304,0))  --"攻击力变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c21521304.atkcon)
	e1:SetOperation(c21521304.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只超量怪兽和自己墓地1只「希望皇 霍普」怪兽为对象才能发动。那只自己场上的超量怪兽除外，那只墓地的怪兽特殊召唤。那之后，自己回复1250基本分。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21521304,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c21521304.spcost)
	e2:SetTarget(c21521304.sptg)
	e2:SetOperation(c21521304.spop)
	c:RegisterEffect(e2)
end
-- 将这张卡登记为No.39的XYZ怪兽（用于No.字段相关判定）。
aux.xyz_number[21521304]=39
-- 效果①的发动条件：这张卡以超量召唤方式成功特殊召唤。
function c21521304.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的处理：将对方场上所有表侧表示怪兽的攻击力暂时变为0。
function c21521304.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- ②效果的发动代价：取除这张卡的1个超量素材。
function c21521304.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- “自己场上1只超量怪兽”的筛选条件：表侧表示的超量怪兽且可以除外。
function c21521304.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
end
-- “自己墓地1只「希望皇 霍普」怪兽”的筛选条件：卡名含有「希望皇」字段且可以被特殊召唤。
function c21521304.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件检查：确认己方场上有可除外的超量怪兽、墓地有可特殊召唤的希望皇怪兽，且主要怪兽区有空位。
function c21521304.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查己方主要怪兽区是否有可用空格（此处>-1允许先除外后腾出位置的情况）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查己方场上是否存在1张可除外的表侧表示超量怪兽作为对象。
		and Duel.IsExistingTarget(c21521304.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在1张可特殊召唤的「希望皇 霍普」怪兽作为对象。
		and Duel.IsExistingTarget(c21521304.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从己方场上选择1只表侧表示超量怪兽，并登记为效果对象（将被除外）。
	local g1=Duel.SelectTarget(tp,c21521304.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只「希望皇 霍普」怪兽，并登记为效果对象（将被特殊召唤）。
	local g2=Duel.SelectTarget(tp,c21521304.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将g1中的卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,0,0)
	-- 设置效果处理信息：将g2中的卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	-- 设置效果处理信息：自己回复1250基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,1250)
end
-- ②效果处理：除外己方1只超量怪兽，从墓地特殊召唤1只希望皇怪兽，然后回复1250基本分；若中间步骤失败则中止。
function c21521304.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理中记录的除外对象。
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	-- 获取效果处理中记录的特殊召唤对象。
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	-- 确认要除外的超量怪兽仍与效果相关，然后将其表侧表示除外；否则中止处理。
	if not tc1:IsRelateToEffect(e) or Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)==0 then return end
	local tc2=g2:GetFirst()
	-- 确认要特殊召唤的墓地怪兽仍与效果相关，然后将其表侧表示特殊召唤；否则中止处理。
	if not tc2:IsRelateToEffect(e) or Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 中断当前效果处理，使后续回复LP成为独立时点。
	Duel.BreakEffect()
	-- 自己回复1250基本分。
	Duel.Recover(tp,1250,REASON_EFFECT)
end
