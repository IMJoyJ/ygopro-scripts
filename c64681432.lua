--破壊竜ガンドラ
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：把基本分支付一半才能发动。场上的其他卡全部破坏并除外。这张卡的攻击力上升这个效果破坏的卡数量×300。
-- ②：这张卡召唤·反转召唤的回合的结束阶段发动。这张卡送去墓地。
function c64681432.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转召唤的回合的结束阶段发动。这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c64681432.tgreg1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetOperation(c64681432.tgreg2)
	c:RegisterEffect(e3)
	-- ①：把基本分支付一半才能发动。场上的其他卡全部破坏并除外。这张卡的攻击力上升这个效果破坏的卡数量×300。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(64681432,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c64681432.descost)
	e4:SetTarget(c64681432.destg)
	e4:SetOperation(c64681432.desop)
	c:RegisterEffect(e4)
	-- ②：这张卡召唤·反转召唤的回合的结束阶段发动。这张卡送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetDescription(aux.Stringid(64681432,1))  --"送去墓地"
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c64681432.tgcon)
	e5:SetTarget(c64681432.tgtg)
	e5:SetOperation(c64681432.tgop)
	c:RegisterEffect(e5)
end
-- ①号效果的支付代价（Cost）函数：支付一半基本分
function c64681432.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 玩家支付当前基本分一半的数值作为发动代价
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ①号效果的发动准备（Target）函数：检查场上是否存在除自身以外可以除外的卡，并设置破坏效果的操作信息
function c64681432.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，确认场上是否存在至少1张除自身以外可以被除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除自身以外所有可以被除外的卡片组
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁的操作信息，表明此效果将破坏上述获取的卡片组中的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①号效果的效果处理（Operation）函数：破坏并除外场上其他卡，并根据破坏数量提升自身攻击力
function c64681432.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除自身以外的所有卡片组
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 因效果破坏上述卡片组，并将其送去除外区，返回实际被破坏的卡片数量
	local ct=Duel.Destroy(sg,REASON_EFFECT,LOCATION_REMOVED)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升这个效果破坏的卡数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 通常召唤成功时，给自身注册一个持续到回合结束的标志（Flag），用于记录本回合进行了通常召唤
function c64681432.tgreg1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(64681432,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 翻转召唤成功时，给自身注册一个持续到回合结束的标志（Flag），用于记录本回合进行了翻转召唤
function c64681432.tgreg2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(64681432,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- ②号效果的发动条件：检查自身是否存在召唤或反转召唤成功的标志
function c64681432.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(64681432)~=0
end
-- ②号效果的发动准备（Target）函数：设置将自身送去墓地的操作信息
function c64681432.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明此效果将把自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的效果处理（Operation）函数：将自身送去墓地
function c64681432.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 因效果将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
