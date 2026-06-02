--オレイカルコスの魔封剣
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的效果无效化。
-- ②：自己的场地区域有卡存在的场合，以自己场上1只效果怪兽为对象才能发动。那只效果怪兽直到对方回合结束时得到以下效果。
-- ●自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
local s,id,o=GetID()
-- 初始化山铜魔封剑的卡片效果，注册装备魔法的发动与装备限制，以及①和②的效果。
function s.initial_effect(c)
	-- 注册该装备魔法的最基础发动效果与可以装备给任意场上表侧表示怪兽的装备限制。
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- ①：装备怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	-- ②：自己的场地区域有卡存在的场合，以自己场上1只效果怪兽为对象才能发动。那只效果怪兽直到对方回合结束时得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"得到效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件：自己的场地区域有卡存在。
function s.effcon(e)
	-- 判断自己的场地区域是否存在任意卡片。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
-- 效果②的怪兽目标过滤条件：表侧表示的效果怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果②的靶向/目标选择与发动可行性判定：在己方场上存在表侧表示的效果怪兽时才能发动，并选择1只效果怪兽作为连锁对象。
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 判断己方场上是否存在表侧表示的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择作为效果②对象的表侧表示效果怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择己方场上1只表侧表示的效果怪兽作为连锁对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的执行操作：使选中的效果怪兽直到对方回合结束时获得相应的表侧表示卡破坏效果，并为其注册相关的客户端状态提示。
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的第一个效果对象（即获得新效果的目标效果怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)
		and not tc:IsImmuneToEffect(e) then
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN+RESET_OPPO_TURN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"「山铜魔封剑」效果适用中"
		-- ●自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
		local e2=Effect.CreateEffect(tc)
		e2:SetDescription(aux.Stringid(id,2))  --"破坏效果（山铜魔封剑）"
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_MZONE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e2:SetCountLimit(1)
		e2:SetCost(s.descost)
		e2:SetTarget(s.destg)
		e2:SetOperation(s.desop)
		tc:RegisterEffect(e2)
	end
end
-- 赋予该怪兽的效果的Cost（代价）处理：判断手牌中是否存在能送去墓地的卡片，并在发动时选择1张手卡送去墓地。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时代价判定：检查手牌中是否有除了本卡以外的可以送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向对方玩家发送提示信息，表明己方发动了破坏效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 让玩家选择并将1张手牌送去墓地作为发动的代价。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 赋予该怪兽的效果破坏的过滤条件：过滤场上的表侧表示卡。
function s.desfilter(c)
	return c:IsFaceup()
end
-- 赋予该怪兽的效果的目标选择与发动可行性判定：需要场上有可以作为对象的表侧表示卡，选择1张卡作为连锁对象，并设置效果处理操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 效果发动时靶向判定：检查场上是否存在可以作为对象的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的表侧表示卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示卡作为破坏对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时的操作信息：预计将选中的表侧表示卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 赋予该怪兽的效果的执行操作：破坏被选为对象的表侧表示卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的第一个连锁对象（即要破坏的表侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		-- 破坏被选为对象的表侧表示卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
