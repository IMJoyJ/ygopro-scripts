--魔妖仙獣 大刃禍是
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己场上的「妖仙兽」怪兽的攻击宣言时才能发动。那只攻击怪兽的攻击力直到战斗阶段结束时上升300。
-- 【怪兽效果】
-- 这张卡不用灵摆召唤不能特殊召唤。
-- ①：这张卡的灵摆召唤不会被无效化。
-- ②：这张卡召唤·特殊召唤成功的场合，以场上最多2张卡为对象才能发动。那些卡回到持有者手卡。
-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c93368494.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（包括灵摆召唤和灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「妖仙兽」怪兽的攻击宣言时才能发动。那只攻击怪兽的攻击力直到战斗阶段结束时上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93368494,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c93368494.atkcon)
	e2:SetOperation(c93368494.atkop)
	c:RegisterEffect(e2)
	-- 这张卡不用灵摆召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能通过灵摆召唤进行特殊召唤。
	e3:SetValue(aux.penlimit)
	c:RegisterEffect(e3)
	-- ①：这张卡的灵摆召唤不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e4)
	-- ②：这张卡召唤·特殊召唤成功的场合，以场上最多2张卡为对象才能发动。那些卡回到持有者手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(93368494,1))  --"弹回手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(c93368494.thtg)
	e5:SetOperation(c93368494.thop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(93368494,2))  --"返回手卡"
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetCondition(c93368494.retcon)
	e7:SetTarget(c93368494.rettg)
	e7:SetOperation(c93368494.retop)
	c:RegisterEffect(e7)
	if not c93368494.global_check then
		c93368494.global_check=true
		-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(93368494)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的操作为：在怪兽特殊召唤成功时，为该怪兽添加对应的特殊召唤回合标记。
		ge1:SetOperation(aux.sumreg)
		-- 将全局效果注册给系统。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判定灵摆效果的发动条件：攻击怪兽必须是自己场上的「妖仙兽」怪兽。
function c93368494.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	return at:IsControler(tp) and at:IsSetCard(0xb3)
end
-- 处理灵摆效果：使进行攻击的怪兽攻击力直到战斗阶段结束时上升300。
function c93368494.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	if at:IsFaceup() and at:IsRelateToBattle() then
		-- 那只攻击怪兽的攻击力直到战斗阶段结束时上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		at:RegisterEffect(e1)
	end
end
-- 处理召唤·特殊召唤成功时弹卡效果的对象选择与合法性检测。
function c93368494.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 效果发动时的可行性检测：场上必须存在至少1张可以回到手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，要求选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上最多2张可以回到手牌的卡片作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置当前连锁的操作信息，表明此效果包含将选定卡片送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理召唤·特殊召唤成功时弹卡效果：将选中的对象卡片送回持有者手牌。
function c93368494.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤并获取当前连锁中仍与该效果相关的对象卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡片因效果送回持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 判定结束阶段回到手牌效果的发动条件：自身带有特殊召唤成功的回合标记。
function c93368494.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(93368494)~=0
end
-- 处理结束阶段回到手牌效果的目标检测与操作信息设置。
function c93368494.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息，表明此效果包含将自身送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理结束阶段回到手牌效果：将自身送回持有者手牌。
function c93368494.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身因效果送回持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
