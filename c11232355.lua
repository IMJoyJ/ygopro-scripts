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
-- 支付1000基本分的费用处理函数
function c11232355.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，用于判断卡片是否为盖放状态
function c11232355.filter(c)
	return c:IsFacedown()
end
-- 选择目标卡片的处理函数
function c11232355.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c11232355.filter(chkc) end
	-- 检查是否存在满足条件的对方场上的盖放魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c11232355.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 向玩家发送选择破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上一张盖放的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c11232355.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置连锁操作信息，确定将要破坏的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理函数
function c11232355.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断卡片是否为表侧表示的念动力族怪兽
function c11232355.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 触发效果的条件判断函数
function c11232355.sdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有其他念动力族怪兽
	return not Duel.IsExistingMatchingCard(c11232355.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 设置自坏效果的目标处理函数
function c11232355.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，确定将要破坏的卡片为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 自坏效果的处理函数
function c11232355.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
