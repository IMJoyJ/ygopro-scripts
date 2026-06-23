--魔界劇団－デビル・ヒール
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降解放的怪兽的原本攻击力数值。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降自己场上的「魔界剧团」怪兽数量×1000。
-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡在自己场上盖放。
function c52240819.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
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
	-- 检测当前效果是否与本次战斗有关（即是否是与对方怪兽战斗）
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(c52240819.settg)
	e4:SetOperation(c52240819.setop)
	c:RegisterEffect(e4)
end
-- 检查玩家场上是否存在至少1张满足条件的「魔界剧团」怪兽可解放，并选择该怪兽进行解放
function c52240819.atkcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的「魔界剧团」怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x10ec) end
	-- 从玩家场上选择1张满足条件的「魔界剧团」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x10ec)
	e:SetLabel(g:GetFirst():GetBaseAttack())
	-- 以REASON_COST原因将目标卡组解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标为对方场上的1只表侧表示怪兽
function c52240819.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上的1只表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽的攻击力直到回合结束时下降解放的怪兽的原本攻击力数值
function c52240819.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设置的效果对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为对象怪兽添加攻击力减少效果，数值等于解放怪兽的原本攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义过滤函数：判断是否为「魔界剧团」且表侧表示的怪兽
function c52240819.atkfilter(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup()
end
-- 设置效果的目标为对方场上的1只表侧表示怪兽，并检查自己场上是否存在至少1只「魔界剧团」怪兽
function c52240819.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只「魔界剧团」怪兽
		and Duel.IsExistingMatchingCard(c52240819.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对方场上的1只表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽的攻击力直到回合结束时下降自己场上的「魔界剧团」怪兽数量×1000
function c52240819.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设置的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 计算自己场上「魔界剧团」怪兽数量并乘以1000作为攻击力减少数值
		local atkval=Duel.GetMatchingGroupCount(c52240819.atkfilter,tp,LOCATION_MZONE,0,nil)*1000
		-- 为对象怪兽添加攻击力减少效果，数值等于自己场上的「魔界剧团」怪兽数量×1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义过滤函数：判断是否为「魔界台本」魔法卡且可盖放
function c52240819.cfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 设置效果的目标为自己的墓地中的1张「魔界台本」魔法卡
function c52240819.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52240819.cfilter(chkc) end
	-- 检查自己墓地中是否存在至少1张「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52240819.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的「魔界台本」魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地中选择1张「魔界台本」魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c52240819.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前处理的连锁的操作信息，包含将卡从墓地移除并盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 将目标魔法卡在自己场上盖放
function c52240819.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标魔法卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
