--No.49 秘鳥フォーチュンチュン
-- 效果：
-- 3星怪兽×2
-- 这个卡名的④的效果1回合只能使用1次。
-- ①：场上的这张卡不会成为效果的对象。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
-- ③：自己准备阶段发动。自己回复500基本分。
-- ④：这张卡从场上送去墓地的场合，以自己墓地2只3星怪兽为对象发动。那2只怪兽回到卡组，这张卡回到额外卡组。
function c16259549.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只等级3的怪兽作为超量素材来XYZ召唤。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ③：自己准备阶段发动。自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16259549,0))  --"回复"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c16259549.reccon)
	e1:SetTarget(c16259549.rectg)
	e1:SetOperation(c16259549.recop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不会成为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c16259549.reptg)
	c:RegisterEffect(e3)
	-- 这个卡名的④的效果1回合只能使用1次。④：这张卡从场上送去墓地的场合，以自己墓地2只3星怪兽为对象发动。那2只怪兽回到卡组，这张卡回到额外卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16259549,1))  --"返回卡组"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,16259549)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c16259549.tdcon)
	e4:SetTarget(c16259549.tdtg)
	e4:SetOperation(c16259549.tdop)
	c:RegisterEffect(e4)
end
-- 将这张卡的XYZ编号登记为49，用于No.相关字段或效果判定。
aux.xyz_number[16259549]=49
-- ③效果的发动条件：仅在当前回合玩家是自己（即自己的准备阶段）时才满足。
function c16259549.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保③效果只在自己准备阶段触发。
	return Duel.GetTurnPlayer()==tp
end
-- ③效果的发动时处理：设置回复对象为自己、回复数值为500，并登记回复效果的操作信息。
function c16259549.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为自己，表示回复LP的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为500，表示回复的数值为500。
	Duel.SetTargetParam(500)
	-- 登记效果处理信息：执行回复500LP的效果；目标玩家为自己，数值为500。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ③效果处理时的实际动作：取得之前设置的玩家和数值，并执行回复LP。
function c16259549.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家和回复数值（在发动时通过SetTargetPlayer/SetTargetParam设置）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p回复d点LP（REASON_EFFECT表示因效果而回复）。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- ②效果的条件判断：这张卡将要被战斗或效果破坏，且不是被代替破坏时，检查能否取除1个超量素材作为代替破坏的代价。
function c16259549.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 弹出让控制者选择是否发动代替破坏的确认框，玩家选择“是”才执行取除素材。
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
-- ④效果的发动条件：这张卡是从场上被送去墓地的场合（排除从手卡/卡组直接送墓的情况）。
function c16259549.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义④效果可选对象的筛选条件：必须是等级3、能成为效果对象、且能返回卡组的卡。
function c16259549.filter(c,e)
	return c:IsLevel(3) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
-- ④效果的发动时选择对象：从自己墓地选2只3星怪兽为对象，并将该卡自身也设定为回额外卡组的对象；若墓地可选卡不足2张则不满足发动条件。
function c16259549.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16259549.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取自己墓地里满足条件的3星怪兽集合（不取对象地搜索，稍后选择其中2只）。
	local g=Duel.GetMatchingGroup(c16259549.filter,tp,LOCATION_GRAVE,0,nil,e)
	if g:GetCount()>=2 then
		-- 弹出选择提示，提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的两只怪兽设为当前连锁的对象（取对象）。
		Duel.SetTargetCard(sg)
		-- 登记操作信息：将2只对象怪兽返回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
		-- 登记操作信息：将这张卡自身返回额外卡组。
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	end
end
-- ④效果处理时：取回对象怪兽，若仍能被此效果处理则将其返回卡组；随后若这张卡仍与此效果关联，则也返回额外卡组。
function c16259549.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时的对象卡组（发动时选择的2只3星怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 then return end
	-- 将选中的2只3星怪兽返回持有者的卡组并洗牌（REASON_EFFECT）。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡No.49自身返回持有者的额外卡组并洗牌（REASON_EFFECT）。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
