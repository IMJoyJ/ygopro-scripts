--No.98 絶望皇ホープレス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那只怪兽变成守备表示。
-- ②：这张卡在墓地存在的场合，以场上1只「希望皇 霍普」怪兽为对象才能发动。这张卡守备表示特殊召唤，把作为对象的怪兽在下面重叠作为超量素材。这个效果在对方回合也能发动。
function c55470553.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己或者对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那只怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55470553,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c55470553.poscost)
	e1:SetTarget(c55470553.postg)
	e1:SetOperation(c55470553.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以场上1只「希望皇 霍普」怪兽为对象才能发动。这张卡守备表示特殊召唤，把作为对象的怪兽在下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55470553,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,55470553)
	e2:SetTarget(c55470553.sptg)
	e2:SetOperation(c55470553.spop)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的「No.」数值为98
aux.xyz_number[55470553]=98
-- 效果①的代价：检查并取除这张卡的1个超量素材
function c55470553.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的靶向/发动条件判定：检查攻击怪兽是否为攻击表示且可以改变表示形式
function c55470553.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前宣告攻击的怪兽
		local at=Duel.GetAttacker()
		return at:IsAttackPos() and at:IsCanChangePosition()
	end
end
-- 效果①的处理：若攻击怪兽仍处于攻击表示且处于战斗中，则将其变为表侧守备表示
function c55470553.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前宣告攻击的怪兽
	local at=Duel.GetAttacker()
	if at:IsAttackPos() and at:IsRelateToBattle() then
		-- 将攻击怪兽变为表侧守备表示
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：场上表侧表示的「希望皇 霍普」怪兽，且可以作为超量素材
function c55470553.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsCanOverlay()
end
-- 效果②的靶向/发动条件判定：检查自身是否能守备表示特殊召唤、主怪兽区是否有空位，以及场上是否存在满足条件的「希望皇 霍普」怪兽
function c55470553.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55470553.spfilter(chkc) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查自身特殊召唤所需的怪兽区域空位是否大于0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以作为效果对象的「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c55470553.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择场上1只「希望皇 霍普」怪兽作为效果对象
	Duel.SelectTarget(tp,c55470553.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将自身守备表示特殊召唤，并将作为对象的怪兽重叠在下面作为超量素材
function c55470553.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的「希望皇 霍普」怪兽
	local tc=Duel.GetFirstTarget()
	-- 若此卡仍与效果相关，则将其以表侧守备表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanOverlay() then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 根据规则，将作为对象的怪兽原本拥有的超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将作为对象的怪兽重叠在此卡下方作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
