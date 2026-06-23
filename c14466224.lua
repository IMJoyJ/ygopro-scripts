--The アトモスフィア
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的2只怪兽和自己墓地存在的1只怪兽从游戏中除外的场合可以特殊召唤。1回合1次，可以把对方场上表侧表示存在的怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
function c14466224.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤规则，需要除外自己场上2只怪兽和自己墓地1只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14466224.spcon)
	e1:SetTarget(c14466224.sptg)
	e1:SetOperation(c14466224.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把对方场上表侧表示存在的怪兽当作装备卡使用只有1只给这张卡装备
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14466224,0))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c14466224.eqcon)
	e2:SetTarget(c14466224.eqtg)
	e2:SetOperation(c14466224.eqop)
	c:RegisterEffect(e2)
end
-- 用于过滤满足特殊召唤条件的怪兽（怪兽卡且可除外）
function c14466224.gfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 用于检查组中是否包含满足条件的墓地怪兽和场上的怪兽
function c14466224.fcheck(c,g)
	return c:IsLocation(LOCATION_GRAVE) and g:IsExists(Card.IsLocation,2,c,LOCATION_MZONE)
end
-- 用于检查组是否满足特殊召唤条件（3张卡，其中2张在场，1张在墓地）
function c14466224.fselect(g,tp)
	-- 检查组是否满足特殊召唤条件（场上的怪兽数量符合要求且包含墓地怪兽）
	return aux.mzctcheck(g,tp) and g:IsExists(c14466224.fcheck,1,nil,g)
end
-- 判断特殊召唤条件是否满足（需要除外3张卡）
function c14466224.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上和墓地的怪兽组
	local g=Duel.GetMatchingGroup(c14466224.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c14466224.fselect,3,3,tp)
end
-- 设置特殊召唤目标（选择除外的3张卡）
function c14466224.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上和墓地的怪兽组
	local g=Duel.GetMatchingGroup(c14466224.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,c14466224.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作（将选中的卡除外）
function c14466224.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断装备效果是否可以发动
function c14466224.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(14466224)==0
end
-- 用于过滤对方场上的可装备怪兽
function c14466224.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 设置装备效果的目标（选择对方场上的怪兽）
function c14466224.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c14466224.filter(chkc) end
	-- 检查装备效果是否可以发动（场上是否有空魔陷区）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否有可装备的怪兽
		and Duel.IsExistingTarget(c14466224.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择对方场上的一个怪兽作为装备目标
	local g=Duel.SelectTarget(tp,c14466224.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制效果的处理函数
function c14466224.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备效果（将怪兽装备给自身）
function c14466224.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		local def=tc:GetTextDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 尝试将目标怪兽装备给自身
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(14466224,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 设置装备限制效果，防止被其他效果装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c14466224.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 装备怪兽的攻击力上升效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
		if def>0 then
			-- 装备怪兽的守备力上升效果
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e3:SetCode(EFFECT_UPDATE_DEFENSE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(def)
			tc:RegisterEffect(e3)
		end
	end
end
