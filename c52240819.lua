--魔界劇団－デビル・ヒール
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降解放的怪兽的原本攻击力数值。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降自己场上的「魔界剧团」怪兽数量×1000。
-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡在自己场上盖放。
function c52240819.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以放置在灵摆区、进行灵摆召唤，并支持灵摆卡的发动等基本灵摆机制。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52240819,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c52240819.atkcost1)
	e1:SetTarget(c52240819.atktg1)
	e1:SetOperation(c52240819.atkop1)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降自己场上的「魔界剧团」怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c52240819.atktg2)
	e2:SetOperation(c52240819.atkop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置该效果的发动条件为：这张卡在与对方怪兽的战斗中直接将其战斗破坏并送入墓地（由aux.bdocon判定此卡与本次战斗相关且对手为对方怪兽）。
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(c52240819.settg)
	e4:SetOperation(c52240819.setop)
	c:RegisterEffect(e4)
end
-- 该函数是灵摆效果的代价处理：从自己场上选择1只「魔界剧团」怪兽解放，并将其原本攻击力记录到效果标签中，供后续效果处理使用。
function c52240819.atkcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放且属于「魔界剧团」的怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x10ec) end
	-- 在满足代价条件后，让玩家从自己场上选择1只「魔界剧团」怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x10ec)
	e:SetLabel(g:GetFirst():GetBaseAttack())
	-- 将选中的怪兽以“代价”这一原因解放，完成效果发动所需的cost。
	Duel.Release(g,REASON_COST)
end
-- 该函数是灵摆效果的目标选择部分：只能选择对方场上1只表侧表示怪兽作为对象，且该怪兽必须能成为效果对象。
function c52240819.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示怪兽可作为效果对象，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示，提示内容为“请选择表侧表示的卡”，用于引导对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将其设定为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 该函数是灵摆效果的处理部分：若效果发动者仍在场上且对象怪兽仍满足表侧表示并和该效果相关，则使对象怪兽攻击力下降解放怪兽的原本攻击力数值，直到回合结束。
function c52240819.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象（即之前选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时下降解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 该过滤器用于筛选表侧表示且属于「魔界剧团」的怪兽，后续用来统计自己场上该类怪兽的数量。
function c52240819.atkfilter(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup()
end
-- 该函数是怪兽效果①的目标选择与发动条件判定：需要选择对方场上1只表侧表示怪兽作为对象，同时确认自己场上存在至少1只表侧表示的「魔界剧团」怪兽。
function c52240819.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 同时检查自己场上是否存在至少1只表侧表示的「魔界剧团」怪兽，作为计算下降数值的基数；两个条件都满足才能发动。
		and Duel.IsExistingMatchingCard(c52240819.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择对象前向玩家发送“请选择表侧表示的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将其设定为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 该函数是怪兽效果①的处理部分：若对象怪兽仍表侧表示且与该效果相关，则计算自己场上表侧表示的「魔界剧团」怪兽数量×1000，使对象怪兽攻击力下降该数值，直到回合结束。
function c52240819.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象（即之前选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 统计自己场上表侧表示的「魔界剧团」怪兽数量，并乘以1000，得到本次需要下降的攻击力数值。
		local atkval=Duel.GetMatchingGroupCount(c52240819.atkfilter,tp,LOCATION_MZONE,0,nil)*1000
		-- 那只怪兽的攻击力直到回合结束时下降自己场上的「魔界剧团」怪兽数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 该过滤器用于筛选墓地中属于「魔界台本」且为魔法卡、同时可以盖放的卡片。
function c52240819.cfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 该函数是怪兽效果②的目标选择部分：从自己墓地选择1张符合条件的「魔界台本」魔法卡作为对象，并设置相关操作信息。
function c52240819.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52240819.cfilter(chkc) end
	-- 检查自己墓地是否存在至少1张满足条件的「魔界台本」魔法卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52240819.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送“请选择要盖放的卡”的提示，引导选择墓地中的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张符合条件的「魔界台本」魔法卡，并将其设定为当前连锁的效果对象（同时与效果建立联系）。
	local g=Duel.SelectTarget(tp,c52240819.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的处理操作信息，表明该效果会使卡从墓地离开（涉及墓地卡片的移动），以便其他卡进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 该函数是怪兽效果②的处理部分：若对象卡片仍然与效果相关，则将其在自己场上以里侧表示盖放。
function c52240819.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（即之前选择的墓地中的「魔界台本」魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象魔法卡以里侧表示放置到己方魔法与陷阱区域，完成盖放。
		Duel.SSet(tp,tc)
	end
end
