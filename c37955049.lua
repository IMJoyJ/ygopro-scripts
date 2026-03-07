--軍神ガープ
-- 效果：
-- 只要这张卡在场上表侧表示存在，场上存在的怪兽全部变成表侧攻击表示，表示形式不能改变。（这个时候，反转效果怪兽的效果不发动。）此外，1回合只有1次可以把手卡的恶魔族怪兽给对方观看，这张卡的攻击力直到结束阶段时上升观看的卡数量×300的数值。
function c37955049.initial_effect(c)
	-- 卡片效果原文：只要这张卡在场上表侧表示存在，场上存在的怪兽全部变成表侧攻击表示，表示形式不能改变。（这个时候，反转效果怪兽的效果不发动。）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+NO_FLIP_EFFECT)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e2)
	-- 卡片效果原文：此外，1回合只有1次可以把手卡的恶魔族怪兽给对方观看，这张卡的攻击力直到结束阶段时上升观看的卡数量×300的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37955049,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c37955049.atcost)
	e3:SetOperation(c37955049.atop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡中是否存在未公开的恶魔族怪兽
function c37955049.cfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsPublic()
end
-- 效果处理函数，用于选择并确认对方观看手卡中的恶魔族怪兽，并将观看数量记录到效果标签中
function c37955049.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡中是否存在至少一张未公开的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37955049.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从玩家手卡中选择1到6张未公开的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c37955049.cfilter,tp,LOCATION_HAND,0,1,63,nil)
	-- 向对方玩家确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手卡进行洗切
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetCount())
end
-- 效果处理函数，用于提升自身攻击力，提升数值为确认观看的恶魔族怪兽数量乘以300
function c37955049.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 为自身效果增加攻击力，提升数值为效果标签中记录的恶魔族怪兽数量乘以300，并在结束阶段重置
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(e:GetLabel()*300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
