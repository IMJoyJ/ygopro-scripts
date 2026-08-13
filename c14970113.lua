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
	-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
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
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把这张卡以外的场上的「十二兽」怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c14970113.efftg)
	e3:SetCondition(c14970113.effcon)
	-- 设置该效果的数值函数为aux.tgoval，使保护效果仅对对方发动的效果生效：当效果发动者不是这张卡的控制者时，对方不能以本卡以外的「十二兽」怪兽为对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：自己·对方的结束阶段发动。这张卡1个超量素材取除。
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
-- 超量召唤手续的叠放对象过滤：选择自己场上表侧表示的、属于「十二兽」字段且不是本卡（「十二兽 猴槌」）的怪兽，作为在其上重叠超量召唤的素材。
function c14970113.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(14970113)
end
-- 实现「1回合1次」限制的额外超量召唤操作函数：chk==0时检查本回合是否已使用过此方式（无誓约标记才可行），chk非0时为本回合已使用登记誓约标记。
function c14970113.xyzop(e,tp,chk)
	-- 在手续检查时，确认当前玩家没有本回合已使用过该额外召唤方式的誓约标记（数量为0），否则不能进行。
	if chk==0 then return Duel.GetFlagEffect(tp,14970113)==0 end
	-- 给当前玩家注册编号为14970113的誓约标记，回合结束阶段重置，代表本回合已经使用过该特殊召唤方式，以禁止同回合内再次使用。
	Duel.RegisterFlagEffect(tp,14970113,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 筛选可作为攻击力上升计算对象的超量素材：属于「十二兽」字段且攻击力不低于0的卡。
function c14970113.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算攻击力上升值：取出本卡全部超量素材中符合atkfilter的卡片，将这些卡的当前攻击力合计作为上升值。
function c14970113.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c14970113.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 筛选可作为守备力上升计算对象的超量素材：属于「十二兽」字段且守备力不低于0的卡。
function c14970113.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算守备力上升值：取出本卡全部超量素材中符合deffilter的卡片，将这些卡的当前守备力合计作为上升值。
function c14970113.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c14970113.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 效果②的保护对象判定：被保护卡必须是场上属于「十二兽」字段的怪兽，且不是本卡自身（即本卡以外的「十二兽」怪兽）。
function c14970113.efftg(e,c)
	return c:IsSetCard(0xf1) and c~=e:GetHandler()
end
-- 效果②的适用条件：这张卡拥有超量素材（叠放数量大于0）时，保护效果才适用。
function c14970113.effcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果③的发动条件判定：该效果为结束阶段必发效果，不需要选择对象，chk==0时直接返回true，并通过提示向对方展示将要取除素材。
function c14970113.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家（1-tp）发送操作选择提示，告知对方本卡发动了“这张卡1个超量素材取除”的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果③的处理：由当前玩家将这张卡上叠放的1个超量素材取除（理由为效果）。
function c14970113.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
