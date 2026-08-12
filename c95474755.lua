--No.89 電脳獣ディアブロシス
-- 效果：
-- 7星怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。把对方的额外卡组确认，选那之内的1张里侧表示除外。
-- ②：这张卡战斗破坏怪兽的战斗阶段结束时，以对方墓地1张卡为对象才能发动。那张卡里侧表示除外。
-- ③：对方的卡被里侧表示除外的场合才能发动。把里侧表示除外中的对方的卡数量的卡从对方卡组上面里侧表示除外。
function c95474755.initial_effect(c)
	-- 添加XYZ召唤手续：7星怪兽2只
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。把对方的额外卡组确认，选那之内的1张里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95474755,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95474755.excost)
	e1:SetTarget(c95474755.extg)
	e1:SetOperation(c95474755.exop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时，以对方墓地1张卡为对象才能发动。那张卡里侧表示除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95474755,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c95474755.grcon)
	e2:SetTarget(c95474755.grtg)
	e2:SetOperation(c95474755.grop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时，以对方墓地1张卡为对象才能发动。那张卡里侧表示除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(c95474755.regop)
	c:RegisterEffect(e3)
	-- ③：对方的卡被里侧表示除外的场合才能发动。把里侧表示除外中的对方的卡数量的卡从对方卡组上面里侧表示除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95474755,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,95474755)
	e4:SetCondition(c95474755.dkcon)
	e4:SetTarget(c95474755.dktg)
	e4:SetOperation(c95474755.dkop)
	c:RegisterEffect(e4)
end
-- 设置该怪兽的“No.”数值为89
aux.xyz_number[95474755]=89
-- 效果①的Cost：检查并把这张卡1个超量素材取除
function c95474755.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的Target：检查对方额外卡组是否存在可以里侧表示除外的卡，并设置操作信息
function c95474755.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否存在至少1张可以里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil,tp,POS_FACEDOWN) end
	-- 设置操作信息：从对方额外卡组将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 效果①的Operation：确认对方额外卡组，选择其中1张卡里侧表示除外，之后洗切对方额外卡组
function c95474755.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 让己方玩家确认对方额外卡组的这些卡
	Duel.ConfirmCards(tp,g,true)
	-- 提示己方玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
	-- 将选中的卡里侧表示除外
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	-- 洗切对方的额外卡组
	Duel.ShuffleExtra(1-tp)
end
-- 战斗破坏怪兽时，为自身注册一个在战斗阶段结束前有效的Flag，用于效果②的发动条件判定
function c95474755.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(95474755,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 效果②的Condition：检查自身是否注册了战斗破坏怪兽的Flag
function c95474755.grcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(95474755)~=0
end
-- 效果②的Target：选择对方墓地1张可以里侧表示除外的卡作为对象，并设置操作信息
function c95474755.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查对方墓地是否存在至少1张可以里侧表示除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil,tp,POS_FACEDOWN) end
	-- 提示己方玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以里侧表示除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil,tp,POS_FACEDOWN)
	-- 设置操作信息：将选中的对方墓地的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果②的Operation：将作为对象的卡里侧表示除外
function c95474755.grop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡里侧表示除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 过滤函数：属于指定玩家且处于里侧表示的卡
function c95474755.dkfilter(c,p)
	return c:IsFacedown() and c:IsControler(p)
end
-- 效果③的Condition：检查是否有对方的卡被里侧表示除外
function c95474755.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95474755.dkfilter,1,nil,1-tp)
end
-- 效果③的Target：计算对方里侧表示除外的卡数量，检查对方卡组顶端是否有等量的卡可以里侧表示除外，并设置操作信息
function c95474755.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方除外区中属于对方的里侧表示的卡片数量
	local ct=Duel.GetMatchingGroupCount(c95474755.dkfilter,tp,0,LOCATION_REMOVED,nil,1-tp)
	-- 获取对方卡组最上方的对应数量的卡
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0
		and tg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct end
	-- 设置操作信息：从对方卡组除外对应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
-- 效果③的Operation：将对方卡组最上方对应数量的卡里侧表示除外
function c95474755.dkop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次计算对方除外区中属于对方的里侧表示的卡片数量
	local ct=Duel.GetMatchingGroupCount(c95474755.dkfilter,tp,0,LOCATION_REMOVED,nil,1-tp)
	if ct==0 then return end
	-- 获取对方卡组最上方的对应数量的卡
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	-- 禁用接下来的洗卡检测（防止在卡组顶端除外卡片时自动洗牌）
	Duel.DisableShuffleCheck()
	-- 将这些卡里侧表示除外
	Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)
end
