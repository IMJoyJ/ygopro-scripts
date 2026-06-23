--アークロード・パラディオン
-- 效果：
-- 包含连接怪兽的效果怪兽2只以上
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ②：这张卡所连接区的怪兽不能攻击。
-- ③：1回合1次，把这张卡所连接区的自己1只「圣像骑士」怪兽或者「星遗物」怪兽解放，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c45002991.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2张以上包含效果怪兽的连接怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c45002991.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c45002991.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c45002991.antg)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡所连接区的自己1只「圣像骑士」怪兽或者「星遗物」怪兽解放，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45002991,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1)
	e3:SetCost(c45002991.discost)
	e3:SetTarget(c45002991.distg)
	e3:SetOperation(c45002991.disop)
	c:RegisterEffect(e3)
end
-- 连接召唤时的检查函数，确保所选素材中至少包含1只连接怪兽
function c45002991.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 计算攻击力上升值，将连接区的表侧表示怪兽的原本攻击力数值相加
function c45002991.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 判断目标怪兽是否在连接区，用于禁止连接区怪兽攻击
function c45002991.antg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 解放怪兽的过滤函数，筛选连接区内的「圣像骑士」或「星遗物」怪兽
function c45002991.cfilter(c,g)
	return c:IsSetCard(0xfe,0x116) and g:IsContains(c)
end
-- 发动效果时的费用处理，检查并选择1只连接区内的「圣像骑士」或「星遗物」怪兽进行解放
function c45002991.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否满足解放条件，即场上有满足条件的怪兽可被解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c45002991.cfilter,1,nil,lg) end
	-- 选择要解放的怪兽，从连接区中选择符合条件的1只怪兽
	local g=Duel.SelectReleaseGroup(tp,c45002991.cfilter,1,1,nil,lg)
	-- 将选中的怪兽进行解放，作为发动效果的费用
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标选择逻辑，选择对方场上的1张表侧表示的卡
function c45002991.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为对方场上的卡且可成为无效化对象
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在可无效化的卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定将要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果的处理函数，使目标卡的效果无效
function c45002991.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效化，直到回合结束
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 若目标卡为陷阱怪兽，则使其陷阱怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
