--ディストラクター
-- 效果：
-- 支付1000基本分才能发动。选择对方场上盖放的1张魔法·陷阱卡破坏。此外，双方的结束阶段时，自己场上没有这张卡以外的念动力族怪兽存在的场合，这张卡破坏。
function c11232355.initial_effect(c)
	-- 支付1000基本分才能发动。选择对方场上盖放的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11232355,0))  --"魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c11232355.descost)
	e1:SetTarget(c11232355.destg)
	e1:SetOperation(c11232355.desop)
	c:RegisterEffect(e1)
	-- 此外，双方的结束阶段时，自己场上没有这张卡以外的念动力族怪兽存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11232355,1))  --"自坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c11232355.sdcon)
	e2:SetTarget(c11232355.sdtg)
	e2:SetOperation(c11232355.sdop)
	c:RegisterEffect(e2)
end
-- 支付1000基本分的发动代价：先检查玩家能否支付1000基本分，能在实际发动时支付。
function c11232355.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家当前能否支付1000基本分，若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付代价：玩家支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 怪兽筛选条件：用于选择对方场上里侧表示的卡，即里侧表示的魔法·陷阱卡。
function c11232355.filter(c)
	return c:IsFacedown()
end
-- 起动效果的目标选择与操作信息登记：选择对方场上里侧表示的1张魔法·陷阱卡为对象，并登记为破坏效果。
function c11232355.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c11232355.filter(chkc) end
	-- 目标存在检查：确认对方魔法·陷阱区存在至少1张里侧表示的卡可供选择。
	if chk==0 then return Duel.IsExistingTarget(c11232355.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 显示选择提示：弹出消息，提示玩家选择要破坏的对方里侧表示的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 执行选择目标：由玩家选择对方场上里侧表示的1张魔法·陷阱卡，并将其登记为效果处理时的对象。
	local g=Duel.SelectTarget(tp,c11232355.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 登记操作信息：将本次连锁的效果标记为破坏1张卡，供后续时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得效果发动时选择的对象卡，若对象仍是里侧表示且与效果存在关联，则将其破坏。
function c11232355.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡，送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 卡片的筛选条件：表侧表示且种族为念动力族，用于判断场上是否存在其他念动力族怪兽。
function c11232355.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 自坏诱发效果的发动条件：自己场上不存在这张卡以外的表侧念动力族怪兽。
function c11232355.sdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查条件：搜索己方主要怪兽区是否存在这卡以外的表侧念动力族怪兽，若不存在则条件满足。
	return not Duel.IsExistingMatchingCard(c11232355.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 自坏效果的目标处理：无对象，直接登记破坏自身这张卡的操作信息。
function c11232355.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：标记将破坏这张卡自身，供时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 自坏效果处理：若这张卡仍表侧表示且与效果关联，则将其破坏。
function c11232355.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 以效果原因破坏这张卡自身。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
