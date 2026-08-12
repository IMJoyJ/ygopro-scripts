--剛鬼ザ・ブレード・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×300。
-- ②：1回合1次，把这张卡所连接区1只自己或者对方的怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c95515058.initial_effect(c)
	-- 设置连接召唤手续，需要2只以上「刚鬼」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c95515058.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡所连接区1只自己或者对方的怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c95515058.atkcon)
	e2:SetCost(c95515058.atkcost)
	e2:SetTarget(c95515058.atktg)
	e2:SetOperation(c95515058.atkop)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升值的辅助函数，返回所连接区的怪兽数量乘以300
function c95515058.atkval(e,c)
	return c:GetLinkedGroupCount()*300
end
-- 效果发动的条件函数，检查当前回合玩家能否进入战斗阶段
function c95515058.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤可以被解放的怪兽
function c95515058.rfilter(c)
	return c:IsReleasable()
end
-- 效果发动的代价函数，解放这张卡所连接区的一只怪兽
function c95515058.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return lg:IsExists(c95515058.rfilter,1,nil) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local g=lg:FilterSelect(tp,c95515058.rfilter,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果发动的目标函数，检查自身是否已经拥有追加攻击的效果
function c95515058.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 效果发动的处理函数，给这张卡添加在同一次战斗阶段中可以作2次攻击的效果
function c95515058.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
