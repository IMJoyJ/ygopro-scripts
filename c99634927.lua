--魔界劇団－ファンキー・コメディアン
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以自己场上1只「魔界剧团」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
-- 【怪兽效果】
-- 「魔界剧团-时髦笑星」的②的怪兽效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽数量×300。
-- ②：以这张卡以外的自己场上1只「魔界剧团」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升这张卡的攻击力数值。
function c99634927.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以作为灵摆怪兽进行灵摆召唤、从手牌发动到灵摆区等。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以自己场上1只「魔界剧团」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99634927,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c99634927.atkcost1)
	e1:SetTarget(c99634927.atktg1)
	e1:SetOperation(c99634927.atkop1)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c99634927.atktg2)
	e2:SetOperation(c99634927.atkop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 「魔界剧团-时髦笑星」的②的怪兽效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。②：以这张卡以外的自己场上1只「魔界剧团」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升这张卡的攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,99634927)
	e4:SetCost(c99634927.atkcost3)
	e4:SetTarget(c99634927.atktg3)
	e4:SetOperation(c99634927.atkop3)
	c:RegisterEffect(e4)
end
-- 定义解放组过滤条件：候选卡必须是「魔界剧团」怪兽，且自己场上还存在另一只表侧表示「魔界剧团」怪兽可作为效果对象（排除候选卡自身）。
function c99634927.atkfilter1(c,tp)
	-- 判断该卡为「魔界剧团」怪兽，并且自己场上存在除它以外的1只表侧表示「魔界剧团」怪兽可作为对象。
	return c:IsSetCard(0x10ec) and Duel.IsExistingTarget(c99634927.atkfilter2,tp,LOCATION_MZONE,0,1,c)
end
-- 定义对象过滤条件：卡是表侧表示且属于「魔界剧团」系列。
function c99634927.atkfilter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup()
end
-- 灵摆效果①的发动代价：从自己场上选择1只符合条件的「魔界剧团」怪兽解放，并将其原本攻击力记录到e:SetLabel中，供后续处理使用。
function c99634927.atkcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价check阶段：确认存在至少1只可解放的「魔界剧团」怪兽（且同时满足场上存在可选对象的条件）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c99634927.atkfilter1,1,nil,tp) end
	-- 选择1只符合条件的「魔界剧团」怪兽作为解放的代价。
	local g=Duel.SelectReleaseGroup(tp,c99634927.atkfilter1,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetBaseAttack())
	-- 将该怪兽解放，解放原因为代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 灵摆效果①的取对象处理：选择自己场上1只表侧表示「魔界剧团」怪兽作为对象；若是连锁处理中回传的chkc对象，则校验其合法。
function c99634927.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c99634927.atkfilter2(chkc) end
	-- 在目标check阶段：确认自己场上存在至少1只表侧表示「魔界剧团」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c99634927.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家弹出选择提示，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示「魔界剧团」怪兽，并将其设置为当前连锁的对象。
	Duel.SelectTarget(tp,c99634927.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果①的发动处理：若效果发动者仍存在、对象仍表侧且仍关联，则给对象施加攻击力上升效果，上升数值为解放怪兽的原本攻击力，直到回合结束。
function c99634927.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该连锁上选取的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 通常召唤成功时的诱发效果目标检查：确认自己场上有表侧表示「魔界剧团」怪兽存在（用于计算数量提升攻击力）。
function c99634927.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上存在至少1只表侧表示「魔界剧团」怪兽，以满足效果发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c99634927.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
end
-- 怪兽效果①的发动处理：统计自己场上表侧表示「魔界剧团」怪兽数量，乘以300作为上升值，给这张卡自身施加攻击力上升，直到回合结束。
function c99634927.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 计算自己场上表侧表示「魔界剧团」怪兽的数量×300，得到攻击力上升数值。
		local atkval=Duel.GetMatchingGroupCount(c99634927.atkfilter2,tp,LOCATION_MZONE,0,nil)*300
		-- 这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 怪兽效果②的发动限制：确认这张卡本回合尚未进行过攻击宣言，并给自己设置‘不能攻击’的誓约效果，持续到回合结束。
function c99634927.atkcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 「魔界剧团-时髦笑星」的②的怪兽效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。②：以这张卡以外的自己场上1只「魔界剧团」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升这张卡的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
-- 怪兽效果②的取对象处理：选择这张卡以外的自己场上1只表侧表示「魔界剧团」怪兽作为对象，校验chkc合法性。
function c99634927.atktg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c99634927.atkfilter2(chkc) end
	-- 在目标check阶段：确认自己场上存在至少1只除这张卡以外的表侧表示「魔界剧团」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c99634927.atkfilter2,tp,LOCATION_MZONE,0,1,c) end
	-- 向玩家弹出选择提示，要求选择自己的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只除这张卡以外的表侧表示「魔界剧团」怪兽，并将其设置为当前连锁的对象。
	Duel.SelectTarget(tp,c99634927.atkfilter2,tp,LOCATION_MZONE,0,1,1,c)
end
-- 怪兽效果②的发动处理：若对象仍表侧且仍关联，则以这张卡的当前攻击力为数值，给对象怪兽施加攻击力上升，直到回合结束。
function c99634927.atkop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该连锁上选取的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=c:GetAttack()
		-- 那只怪兽的攻击力直到回合结束时上升这张卡的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
