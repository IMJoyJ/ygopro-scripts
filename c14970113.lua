--十二獣ハマーコング
-- 效果：
-- 4星怪兽×3只以上
-- 「十二兽 猴槌」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把这张卡以外的场上的「十二兽」怪兽作为效果的对象。
-- ③：自己·对方的结束阶段发动。这张卡1个超量素材取除。
function c14970113.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,3,c14970113.ovfilter,aux.Stringid(14970113,0),99,c14970113.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 效果原文：①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c14970113.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c14970113.defval)
	c:RegisterEffect(e2)
	-- 效果原文：②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把这张卡以外的场上的「十二兽」怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c14970113.efftg)
	e3:SetCondition(c14970113.effcon)
	-- 设置效果值为aux.tgoval函数，用于过滤不能成为对方效果对象的条件。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 效果原文：③：自己·对方的结束阶段发动。这张卡1个超量素材取除。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14970113,1))  --"这张卡1个超量素材取除"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c14970113.rmtg)
	e4:SetOperation(c14970113.rmop)
	c:RegisterEffect(e4)
end
-- 过滤函数：用于判断是否为「十二兽」怪兽且不是猴槌本身。
function c14970113.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(14970113)
end
-- 超量召唤时的处理函数：检查是否已使用过效果，若未使用则注册标识效果。
function c14970113.xyzop(e,tp,chk)
	-- 检查是否已使用过效果，若未使用则返回true。
	if chk==0 then return Duel.GetFlagEffect(tp,14970113)==0 end
	-- 为玩家注册一个标识效果，用于标记该回合已使用过超量召唤效果。
	Duel.RegisterFlagEffect(tp,14970113,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 攻击力计算时的过滤函数：筛选出「十二兽」怪兽且攻击力非负的卡片。
function c14970113.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算攻击力总和：获取当前超量素材中所有「十二兽」怪兽的攻击力总和。
function c14970113.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c14970113.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 守备力计算时的过滤函数：筛选出「十二兽」怪兽且守备力非负的卡片。
function c14970113.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算守备力总和：获取当前超量素材中所有「十二兽」怪兽的守备力总和。
function c14970113.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c14970113.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 效果目标过滤函数：筛选出场上所有「十二兽」怪兽（不包括自身）。
function c14970113.efftg(e,c)
	return c:IsSetCard(0xf1) and c~=e:GetHandler()
end
-- 效果发动条件函数：当该卡拥有超量素材时效果生效。
function c14970113.effcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 取除超量素材的处理函数：在结束阶段发动时提示对方已选择该效果。
function c14970113.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示“对方选择了：这张卡1个超量素材取除”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 取除超量素材的实际操作：从自身移除1个超量素材
function c14970113.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
