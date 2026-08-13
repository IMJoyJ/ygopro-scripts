--ガジェット・トレーラー
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡选「变形斗士」怪兽任意数量送去墓地。这张卡的攻击力上升这个效果送去墓地的怪兽数量×800。
function c28002611.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡选「变形斗士」怪兽任意数量送去墓地。这张卡的攻击力上升这个效果送去墓地的怪兽数量×800。
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
-- 过滤条件：判定卡片是否为「变形斗士」字段的怪兽卡。
function c28002611.filter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER)
end
-- 效果的目标设定：检查手牌是否存在至少1张「变形斗士」怪兽可供选择，并登记把怪兽送去墓地的操作信息。
function c28002611.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的合法性检查：确认我方手牌中存在至少1张符合条件的「变形斗士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28002611.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 登记当前连锁的操作信息：本效果将把手牌的「变形斗士」怪兽送去墓地，预期数量为1张，位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌选择任意数量的「变形斗士」怪兽送去墓地，之后根据送入墓地的数量提高这张卡的攻击力。
function c28002611.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 弹出选择提示，要求玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1至63张满足条件的「变形斗士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28002611.filter,tp,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()==0 then return end
	-- 将选择的卡以效果原因送入墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 这张卡的攻击力上升这个效果送去墓地的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetCount()*800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
