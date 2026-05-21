--宵星の機神ディンギルス
-- 效果：
-- 8星怪兽×2
-- 自己对「宵星之机神 丁吉尔苏」1回合只能有1次特殊召唤，这张卡也能在自己场上的「自奏圣乐」连接怪兽上面重叠来超量召唤。
-- ①：这张卡特殊召唤的场合，可以从以下效果选择1个发动。
-- ●对方场上1张卡送去墓地。
-- ●把自己的除外状态的1只机械族怪兽作为这张卡的超量素材。
-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c93854893.initial_effect(c)
	c:SetSPSummonOnce(93854893)
	aux.AddXyzProcedure(c,nil,8,2,c93854893.ovfilter,aux.Stringid(93854893,0))  --"是否在「自奏圣乐」连接怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，可以从以下效果选择1个发动。●对方场上1张卡送去墓地。●把自己的除外状态的1只机械族怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c93854893.tg)
	e1:SetOperation(c93854893.op)
	c:RegisterEffect(e1)
	-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c93854893.desreptg)
	e2:SetValue(c93854893.desrepval)
	e2:SetOperation(c93854893.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「自奏圣乐」连接怪兽，用于重叠超量召唤
function c93854893.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11b) and c:IsType(TYPE_LINK)
end
-- 过滤除外状态的表侧表示机械族怪兽，且该怪兽可以作为超量素材
function c93854893.ofilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- ①效果的发动准备，检测并让玩家选择发动哪个分支效果，并设置对应的操作信息
function c93854893.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以送去墓地的卡
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查自己除外状态是否存在可以作为超量素材的机械族怪兽
	local b2=Duel.IsExistingMatchingCard(c93854893.ofilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops,opval={},{}
	if b1 then
		ops[off]=aux.Stringid(93854893,1)  --"对方卡送去墓地"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(93854893,2)  --"补充超量素材"
		opval[off]=1
		off=off+1
	end
	-- 让玩家选择要发动的分支效果
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 设置连锁的操作信息为：将对方场上的1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
	else
		e:SetCategory(0)
	end
end
-- ①效果的处理，根据玩家的选择执行对应的分支效果（送墓或补充素材）
function c93854893.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择对方场上1张可以送去墓地的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 闪烁显示被选择的卡片
			Duel.HintSelection(g)
			-- 将选择的卡因效果送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	else
		if not c:IsRelateToEffect(e) then return end
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家选择自己除外状态的1只满足条件的机械族怪兽
		local g=Duel.SelectMatchingCard(tp,c93854893.ofilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽重叠作为这张卡的超量素材
			Duel.Overlay(c,g)
		end
	end
end
-- 过滤自己场上因战斗或效果将被破坏的卡，且该破坏不是代替破坏
function c93854893.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标检测，检查是否有自己场上的卡被破坏，且自身有超量素材可用于取除
function c93854893.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c93854893.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定哪些卡适用代替破坏的保护
function c93854893.desrepval(e,c)
	return c93854893.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的具体操作，取除这张卡的1个超量素材
function c93854893.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 显式展示这张卡发动代替破坏效果的动画
	Duel.Hint(HINT_CARD,0,93854893)
end
