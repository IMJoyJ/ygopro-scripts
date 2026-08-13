--軍神ガープ
-- 效果：
-- 只要这张卡在场上表侧表示存在，场上存在的怪兽全部变成表侧攻击表示，表示形式不能改变。（这个时候，反转效果怪兽的效果不发动。）此外，1回合只有1次可以把手卡的恶魔族怪兽给对方观看，这张卡的攻击力直到结束阶段时上升观看的卡数量×300的数值。
function c37955049.initial_effect(c)
	-- 场上存在的怪兽全部变成表侧攻击表示，反转效果怪兽的效果不发动。
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
	-- 此外，1回合只有1次可以把手卡的恶魔族怪兽给对方观看，这张卡的攻击力直到结束阶段时上升观看的卡数量×300的数值。
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
-- 过滤函数：判定手牌中的卡是否为恶魔族且处于非公开状态，用于筛选可作为展示代价的恶魔族手牌。
function c37955049.cfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsPublic()
end
-- 发动代价处理：从手牌中选择1~63张符合条件的恶魔族怪兽（非公开）展示给对方确认，然后洗切手牌，并将展示数量记录在效果的Label中，供后续攻击力上升效果使用。
function c37955049.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手牌中是否存在至少1张符合条件的恶魔族怪兽（非公开），若不存在则不能支付代价发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c37955049.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送选择提示消息，提示内容为“请选择给对方确认的卡”，引导玩家选择要展示的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让发动玩家从手牌中任意选择1~63张符合条件的恶魔族怪兽（非公开），这些卡将作为给对方确认的代价。
	local g=Duel.SelectMatchingCard(tp,c37955049.cfilter,tp,LOCATION_HAND,0,1,63,nil)
	-- 将选择的手牌全部展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示完毕后洗切手牌，防止对方通过手牌顺序获取额外信息。
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetCount())
end
-- 攻击力提升效果的处理：确认本卡仍在场上且效果关联有效后，为本卡附加一个攻击力上升效果，上升数值为之前记录的展示数量×300，持续到结束阶段。
function c37955049.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到结束阶段时上升观看的卡数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(e:GetLabel()*300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
