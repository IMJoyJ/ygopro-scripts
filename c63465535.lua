--地底のアラクネー
-- 效果：
-- 暗属性调整＋调整以外的昆虫族怪兽1只
-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。1回合1次，可以选择对方场上表侧表示存在的1只怪兽当作装备卡使用只有1只给这张卡装备。这张卡被战斗破坏的场合，可以作为代替把这个效果装备的怪兽破坏。
function c63465535.initial_effect(c)
	-- 设置同调召唤手续：暗属性调整＋调整以外的昆虫族怪兽1只
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_INSECT),1,1)
	c:EnableReviveLimit()
	-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c63465535.aclimit)
	e1:SetCondition(c63465535.actcon)
	c:RegisterEffect(e1)
	-- 1回合1次，可以选择对方场上表侧表示存在的1只怪兽当作装备卡使用只有1只给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63465535,0))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c63465535.eqcon)
	e2:SetTarget(c63465535.eqtg)
	e2:SetOperation(c63465535.eqop)
	c:RegisterEffect(e2)
	-- 这张卡被战斗破坏的场合，可以作为代替把这个效果装备的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c63465535.desreptg)
	e3:SetOperation(c63465535.desrepop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 限制不能发动的卡片类型为魔法·陷阱卡的发动
function c63465535.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 限制不能发动效果的条件为自身进行攻击
function c63465535.actcon(e)
	-- 判定当前攻击的怪兽是否为自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判定装备效果的发动条件：自身没有通过此效果装备的怪兽
function c63465535.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or not ec:IsHasCardTarget(c) or ec:GetFlagEffect(63465535)==0
end
-- 过滤对方场上表侧表示且可以转移控制权的怪兽
function c63465535.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 装备效果的对象选择：检查自身魔陷区空位并选择对方场上1只表侧表示怪兽
function c63465535.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c63465535.filter(chkc) end
	-- 检查自身魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在满足过滤条件的怪兽
		and Duel.IsExistingTarget(c63465535.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63465535.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 限制装备卡只能装备给此卡
function c63465535.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的实际处理：将目标怪兽作为装备卡装备给此卡，并设置装备限制
function c63465535.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽作为装备卡装备给此卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(63465535,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 只有1只给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c63465535.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 代替破坏效果的条件判定：检查自身是否因战斗被破坏，且存在通过此效果装备的怪兽可以代替破坏
function c63465535.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=e:GetLabelObject():GetLabelObject()
	if chk==0 then return c:IsReason(REASON_BATTLE) and ec and ec:IsHasCardTarget(c)
		and ec:IsDestructable(e) and not ec:IsStatus(STATUS_DESTROY_CONFIRMED) and ec:GetFlagEffect(63465535)~=0 end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的实际处理：破坏作为代替的装备怪兽
function c63465535.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏作为代替的装备怪兽
	Duel.Destroy(e:GetLabelObject():GetLabelObject(),REASON_EFFECT+REASON_REPLACE)
end
