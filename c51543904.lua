--No.99 希望皇龍ホープドラグーン
-- 效果：
-- 10星怪兽×3
-- 这张卡也能把手卡1张「升阶魔法」魔法卡丢弃，在自己场上的「希望皇 霍普」怪兽上面重叠来超量召唤。
-- ①：1回合1次，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡为对象的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c51543904.initial_effect(c)
	aux.AddXyzProcedure(c,nil,10,3,c51543904.ovfilter,aux.Stringid(51543904,0),3,c51543904.xyzop)  --"是否在「希望皇 霍普」怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51543904,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51543904.sptg)
	e1:SetOperation(c51543904.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为对象的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51543904,2))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c51543904.discon)
	e2:SetCost(c51543904.discost)
	e2:SetTarget(c51543904.distg)
	e2:SetOperation(c51543904.disop)
	c:RegisterEffect(e2)
end
-- 设置此卡为No.99怪兽
aux.xyz_number[51543904]=99
-- 过滤手牌中可丢弃的「升阶魔法」魔法卡
function c51543904.cfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 判断场上是否存在「希望皇 霍普」怪兽
function c51543904.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 检查是否有满足条件的「升阶魔法」魔法卡并将其丢弃作为召唤代价
function c51543904.xyzop(e,tp,chk)
	-- 检查是否存在满足条件的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51543904.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作
	Duel.DiscardHand(tp,c51543904.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤墓地中的「No.」怪兽
function c51543904.filter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标选择函数
function c51543904.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51543904.filter(chkc,e,tp) end
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c51543904.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c51543904.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤并附加效果
function c51543904.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且进行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果被无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否可以发动此效果
function c51543904.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsActiveType(TYPE_MONSTER) then return end
	-- 获取连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡片组是否包含此卡且该连锁可被无效
	return tg and tg:IsContains(c) and Duel.IsChainNegatable(ev)
end
-- 设置破坏效果的费用支付函数
function c51543904.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置破坏效果的目标选择函数
function c51543904.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行破坏效果
function c51543904.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁无效且目标怪兽有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 执行破坏操作
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
