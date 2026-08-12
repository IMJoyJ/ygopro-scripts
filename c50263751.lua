--グリード・クエーサー
-- 效果：
-- ①：这张卡的原本的攻击力·守备力变成这张卡的等级×300。
-- ②：只要这张卡在怪兽区域存在，这张卡的等级上升这张卡战斗破坏的怪兽的原本等级数值。
function c50263751.initial_effect(c)
	-- ①：这张卡的原本的攻击力·守备力变成这张卡的等级×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c50263751.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡的等级上升这张卡战斗破坏的怪兽的原本等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c50263751.condition)
	e2:SetOperation(c50263751.operation)
	c:RegisterEffect(e2)
end
-- 设置自身原本攻击力为等级乘以300
function c50263751.atkval(e,c)
	return c:GetLevel()*300
end
-- 判断自身是否参与了战斗且处于表侧表示
function c50263751.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle() and e:GetHandler():IsFaceup()
end
-- 处理战斗破坏后等级提升的效果，包括初始化和累加等级值
function c50263751.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local lv=bc:GetLevel()
	if lv>0 then
		if c:GetFlagEffect(50263751)==0 then
			-- 提升自身等级
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			c:RegisterFlagEffect(50263751,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
			e:SetLabelObject(e1)
			e:SetLabel(lv)
		else
			local pe=e:GetLabelObject()
			local ct=e:GetLabel()+lv
			e:SetLabel(ct)
			pe:SetValue(ct)
		end
	end
end
