--ガジェット・トレーラー
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡选「变形斗士」怪兽任意数量送去墓地。这张卡的攻击力上升这个效果送去墓地的怪兽数量×800。
function c28002611.initial_effect(c)
	-- 效果原文内容：①：1回合1次，自己主要阶段才能发动。从手卡选「变形斗士」怪兽任意数量送去墓地。这张卡的攻击力上升这个效果送去墓地的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28002611,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c28002611.tg)
	e1:SetOperation(c28002611.op)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于筛选手卡中属于「变形斗士」且为怪兽的卡片。
function c28002611.filter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER)
end
-- 规则层面作用：设置效果的发动条件，检查玩家手卡中是否存在至少1张符合条件的「变形斗士」怪兽。
function c28002611.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足发动条件，即手卡中是否存在至少1张「变形斗士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28002611.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：设置连锁操作信息，表示该效果会将目标怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：定义效果发动后的处理流程，包括选择并送入墓地的怪兽数量、计算攻击力提升值并应用到自身。
function c28002611.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：让玩家从手卡中选择1到63张符合条件的「变形斗士」怪兽送入墓地。
	local g=Duel.SelectMatchingCard(tp,c28002611.filter,tp,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()==0 then return end
	-- 规则层面作用：将选中的怪兽送入墓地，并记录其为效果原因。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 效果原文内容：这张卡的攻击力上升这个效果送去墓地的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetCount()*800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
