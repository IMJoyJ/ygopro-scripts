--甲纏竜ガイアーム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡解放，以这张卡以外的自己墓地3只同调怪兽为对象才能发动。那些怪兽回到额外卡组。
-- ②：以从额外卡组特殊召唤的自己场上1只怪兽为对象才能发动。墓地的这张卡当作装备卡使用给那只怪兽装备。
-- ③：有这张卡装备的怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
function c49816630.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）＋1只以上调整以外的怪兽，满足后可作为同调素材进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②③的效果1回合各能使用1次。①：把这张卡解放，以这张卡以外的自己墓地3只同调怪兽为对象才能发动。那些怪兽回到额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49816630,0))
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,49816630)
	e1:SetCost(c49816630.tecost)
	e1:SetTarget(c49816630.tetg)
	e1:SetOperation(c49816630.teop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②③的效果1回合各能使用1次。②：以从额外卡组特殊召唤的自己场上1只怪兽为对象才能发动。墓地的这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49816630,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,49816631)
	e2:SetTarget(c49816630.eqtg)
	e2:SetOperation(c49816630.eqop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②③的效果1回合各能使用1次。③：有这张卡装备的怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49816630,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,49816632)
	e3:SetCondition(c49816630.drcon)
	e3:SetTarget(c49816630.drtg)
	e3:SetOperation(c49816630.drop)
	c:RegisterEffect(e3)
end
-- ①效果的代价函数：检查并解放这张卡自身作为发动代价。
function c49816630.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡自身（REASON_COST），作为①效果的发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果的对象过滤条件：选择自己墓地的同调怪兽，且该怪兽能够返回额外卡组。
function c49816630.tefilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- ①效果的目标设定：从自己墓地选择3只符合条件的同调怪兽（不包括这张卡自身）作为对象，并设置返回额外卡组的操作信息。
function c49816630.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己墓地存在至少3只符合条件的同调怪兽（且不是这张卡自身）可选为对象。
	if chk==0 then return Duel.IsExistingTarget(c49816630.tefilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 弹出选择提示：请选择要返回卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择3只符合条件的同调怪兽（排除这张卡自身）作为效果对象。
	local g=Duel.SelectTarget(tp,c49816630.tefilter,tp,LOCATION_GRAVE,0,3,3,e:GetHandler())
	-- 设置操作信息：本次效果将处理3张卡返回额外卡组，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,3,0,0)
end
-- ①效果处理：取回对象卡，筛选仍与效果关联的卡，将其返回持有者的额外卡组并洗牌。
function c49816630.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，过滤掉已不与此效果关联的卡（如对象失效的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因将这些对象卡弹回持有者的额外卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果可装备对象的过滤条件：表侧表示且从额外卡组特殊召唤的怪兽。
function c49816630.eqfilter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end
-- ②效果的目标设定：检查魔陷区空位，选择自己场上的表侧表示且从额外卡组特殊召唤的1只怪兽作为装备对象。
function c49816630.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49816630.eqfilter(chkc) end
	-- 发动条件检查：自己的魔陷区有空位，用于放置这张装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：自己场上存在至少1只符合条件的可装备对象怪兽。
		and Duel.IsExistingTarget(c49816630.eqfilter,tp,LOCATION_MZONE,0,1,nil)
		and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden() end
	-- 弹出选择提示：请选择要装备的卡（HINTMSG_EQUIP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从符合条件的自己怪兽中选择1只作为装备对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c49816630.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：这张卡将离开墓地（作为装备卡装备到对象怪兽身上）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：确认关联与空位后，将墓地的这张卡装备给目标怪兽，并注册装备对象限制。
function c49816630.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取②效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 装备处理前检查：魔陷区没有空位、目标怪兽变为里侧表示或已不关联效果时，本次处理终止。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if not c:CheckUniqueOnField(tp,LOCATION_SZONE) or c:IsForbidden() then return end
	-- 执行装备：将这张卡装备给目标怪兽；装备失败则终止处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 墓地的这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c49816630.eqlimit)
	c:RegisterEffect(e1)
end
-- 装备限制判定：这张装备卡仅允许装备给效果记录的目标怪兽（e:GetLabelObject()）。
function c49816630.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ③效果的发动条件：这张卡的装备怪兽进行战斗的攻击宣言时满足条件。
function c49816630.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽存在，且该怪兽是当前攻击宣言的攻击方或被攻击方，二者满足其一即可发动。
	return ec and (Duel.GetAttacker()==ec or Duel.GetAttackTarget()==ec)
end
-- ③效果发动时设定：确认自己可抽卡后，将目标玩家设为自己、抽卡数设为1，并登记抽卡操作信息。
function c49816630.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己是否满足可以抽1张卡的条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次效果的目标玩家设置为发动者自己（tp）。
	Duel.SetTargetPlayer(tp)
	-- 将目标参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本次效果将处理抽1张卡，目标玩家为tp，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果处理：按记录的目标玩家和抽卡数量执行抽卡，完成“自己从卡组抽1张”。
function c49816630.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果处理时存储的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽d张卡，即自己抽1张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
