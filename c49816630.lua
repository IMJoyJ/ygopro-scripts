--甲纏竜ガイアーム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡解放，以这张卡以外的自己墓地3只同调怪兽为对象才能发动。那些怪兽回到额外卡组。
-- ②：以从额外卡组特殊召唤的自己场上1只怪兽为对象才能发动。墓地的这张卡当作装备卡使用给那只怪兽装备。
-- ③：有这张卡装备的怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
function c49816630.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把这张卡解放，以这张卡以外的自己墓地3只同调怪兽为对象才能发动。那些怪兽回到额外卡组。
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
	-- ②：以从额外卡组特殊召唤的自己场上1只怪兽为对象才能发动。墓地的这张卡当作装备卡使用给那只怪兽装备。
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
	-- ③：有这张卡装备的怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
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
-- 效果处理时检查是否可以解放自身作为费用
function c49816630.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义用于检索墓地中的同调怪兽的过滤条件
function c49816630.tefilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 选择3只满足条件的墓地同调怪兽作为效果对象
function c49816630.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否存在满足条件的3只墓地同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c49816630.tefilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡片组
	local g=Duel.SelectTarget(tp,c49816630.tefilter,tp,LOCATION_GRAVE,0,3,3,e:GetHandler())
	-- 设置连锁操作信息，表示将要将目标卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,3,0,0)
end
-- 效果处理函数，将符合条件的目标卡送回额外卡组
function c49816630.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡片组，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡片送回额外卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 定义用于判断是否为从额外卡组召唤的场上怪兽的过滤条件
function c49816630.eqfilter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 设置装备效果的目标选择逻辑，要求目标为己方场上的正面表示的从额外卡组召唤的怪兽
function c49816630.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49816630.eqfilter(chkc) end
	-- 检查己方魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否存在满足条件的场上怪兽作为装备对象
		and Duel.IsExistingTarget(c49816630.eqfilter,tp,LOCATION_MZONE,0,1,nil)
		and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden() end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c49816630.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要将此卡从墓地移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 装备效果处理函数，执行装备动作并设置装备限制
function c49816630.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中被指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查是否满足装备条件（区域是否足够、目标是否为正面表示且与效果相关）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if not c:CheckUniqueOnField(tp,LOCATION_SZONE) or c:IsForbidden() then return end
	-- 尝试将此卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 创建装备限制效果，确保此卡只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c49816630.eqlimit)
	c:RegisterEffect(e1)
end
-- 装备限制函数，判断装备对象是否为目标怪兽
function c49816630.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击宣言时的触发条件判断函数，检查是否有装备此卡的怪兽参与攻击或被攻击
function c49816630.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断当前是否有装备此卡的怪兽参与了攻击或被攻击
	return ec and (Duel.GetAttacker()==ec or Duel.GetAttackTarget()==ec)
end
-- 设置抽卡效果的目标和参数
function c49816630.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息中的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息中的目标参数为抽卡数量（1张）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，表示将要进行抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果处理函数
function c49816630.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡动作
	Duel.Draw(p,d,REASON_EFFECT)
end
