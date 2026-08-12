--リトマスの死の剣士
-- 效果：
-- 「石蕊的死仪式」降临。
-- ①：这张卡只要在怪兽区域存在，不受陷阱卡的效果影响，不会被战斗破坏。
-- ②：陷阱卡在场上表侧表示存在的场合，这张卡的攻击力·守备力上升3000。
-- ③：仪式召唤的这张卡被对方破坏的场合，以自己或者对方的墓地1张陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c72566043.initial_effect(c)
	-- 注册该卡记有「石蕊的死仪式」卡名的关联关系
	aux.AddCodeList(c,8955148)
	c:EnableReviveLimit()
	-- ①：这张卡只要在怪兽区域存在，不受陷阱卡的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c72566043.efilter)
	c:RegisterEffect(e1)
	-- 不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：陷阱卡在场上表侧表示存在的场合，这张卡的攻击力·守备力上升3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c72566043.atkcon)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：仪式召唤的这张卡被对方破坏的场合，以自己或者对方的墓地1张陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(72566043,0))
	e5:SetCategory(CATEGORY_SSET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(c72566043.setcon)
	e5:SetTarget(c72566043.settg)
	e5:SetOperation(c72566043.setop)
	c:RegisterEffect(e5)
end
-- 过滤出陷阱卡类型的效果，用于不受其影响的过滤函数
function c72566043.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 过滤场上正面表示的陷阱卡的过滤条件
function c72566043.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 攻击力·守备力上升效果的生效条件判定函数
function c72566043.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的陷阱卡
	return Duel.IsExistingMatchingCard(c72566043.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 被对方破坏时发动的条件判定函数
function c72566043.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤自己或对方墓地中能被盖放的陷阱卡的过滤条件
function c72566043.setfilter(c,tp)
	local chk=not c:IsControler(tp)
	-- 检查卡片是否是陷阱卡、是否能被盖放，且若为对方的卡则需要己方魔陷区有空余位置
	return c:IsType(TYPE_TRAP) and c:IsSSetable(chk) and (not chk or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- ③效果的发动可行性检查与对象选择函数（Target）
function c72566043.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c72566043.setfilter(chkc,tp) end
	-- 检查双方墓地中是否存在符合盖放条件的陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c72566043.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择双方墓地中1张符合条件的陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c72566043.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置当前连锁的操作信息：目标卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的结算操作函数（Operation）
function c72566043.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的陷阱卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,tc)
	end
end
