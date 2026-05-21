--No.24 竜血鬼ドラギュラス
-- 效果：
-- 6星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
-- ②：表侧表示的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。这张卡里侧守备表示特殊召唤。
-- ③：这张卡反转的场合发动。选场上1张卡送去墓地。
function c93713837.initial_effect(c)
	-- 添加XYZ召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93713837,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c93713837.poscost)
	e1:SetTarget(c93713837.postg)
	e1:SetOperation(c93713837.posop)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。这张卡里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93713837,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c93713837.spcon)
	e2:SetTarget(c93713837.sptg)
	e2:SetOperation(c93713837.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	-- ③：这张卡反转的场合发动。选场上1张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93713837,2))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP)
	e4:SetTarget(c93713837.tgtg)
	e4:SetOperation(c93713837.tgop)
	c:RegisterEffect(e4)
end
-- 设置该卡片的No.编号为24
aux.xyz_number[93713837]=24
-- ①效果的Cost：检查并把这张卡1个超量素材取除
function c93713837.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：从额外卡组特殊召唤的表侧表示且可以变成里侧表示的怪兽
function c93713837.posfilter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:IsCanTurnSet()
end
-- ①效果的Target：检查并选择1只符合条件的怪兽作为对象，设置操作信息为改变表示形式
function c93713837.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c93713837.posfilter(chkc) end
	-- 在发动效果时，检查场上是否存在至少1只满足过滤条件的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c93713837.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动效果的玩家选择1只满足过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c93713837.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：改变所选卡片的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的Operation：将作为对象的怪兽变成里侧守备表示
function c93713837.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的Condition：检查是否是表侧表示的这张卡因对方的效果从场上离开
function c93713837.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②效果的Target：检查自己场上是否有空位，以及这张卡是否能以里侧守备表示特殊召唤，并设置操作信息
function c93713837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上的怪兽区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的Operation：将这张卡里侧守备表示特殊召唤，并给对方玩家确认
function c93713837.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以里侧守备表示特殊召唤，并判断是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 将特殊召唤的里侧表示卡片给对方玩家进行确认
		Duel.ConfirmCards(1-tp,c)
	end
end
-- ③效果的Target：设置操作信息为将场上的1张卡送去墓地
function c93713837.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有的卡片（作为可选的送去墓地的卡片组）
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息为：将场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ③效果的Operation：选场上1张卡送去墓地
function c93713837.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让发动效果的玩家从场上选择1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为所选的卡片显示被选为效果影响对象的动画效果
		Duel.HintSelection(g)
		-- 因效果将所选的卡片送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
