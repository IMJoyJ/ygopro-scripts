--No.49 秘鳥フォーチュンチュン
-- 效果：
-- 3星怪兽×2
-- 这个卡名的④的效果1回合只能使用1次。
-- ①：场上的这张卡不会成为效果的对象。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
-- ③：自己准备阶段发动。自己回复500基本分。
-- ④：这张卡从场上送去墓地的场合，以自己墓地2只3星怪兽为对象发动。那2只怪兽回到卡组，这张卡回到额外卡组。
function c16259549.initial_effect(c)
	-- 为卡片添加等级为3、需要2只怪兽进行XYZ召唤的手续
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
	-- ④：这张卡从场上送去墓地的场合，以自己墓地2只3星怪兽为对象发动。那2只怪兽回到卡组，这张卡回到额外卡组。
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
-- 设置该卡的XYZ编号为49
aux.xyz_number[16259549]=49
-- 准备阶段效果的发动条件判断函数
function c16259549.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段回复LP效果的目标设定函数
function c16259549.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为回复LP效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 准备阶段回复LP效果的处理函数
function c16259549.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 破坏代替效果的处理函数
function c16259549.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动该效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
-- 墓地效果发动条件判断函数
function c16259549.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤墓地中的3星怪兽函数
function c16259549.filter(c,e)
	return c:IsLevel(3) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
-- 墓地效果的目标设定函数
function c16259549.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16259549.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取满足条件的墓地怪兽数组
	local g=Duel.GetMatchingGroup(c16259549.filter,tp,LOCATION_GRAVE,0,nil,e)
	if g:GetCount()>=2 then
		-- 提示玩家选择要返回卡组的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 设置当前处理的连锁对象为选中的怪兽
		Duel.SetTargetCard(sg)
		-- 设置连锁操作信息为将怪兽送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
		-- 设置连锁操作信息为将自身送回额外卡组
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	end
end
-- 墓地效果的处理函数
function c16259549.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 then return end
	-- 将目标怪兽送回卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送回额外卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
