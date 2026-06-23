--雲魔物－ニンバスマン
-- 效果：
-- 这张卡不会被战斗破坏。这张卡表侧守备表示在场上存在的场合，这张卡破坏。这张卡祭品召唤的场合，可以只用自己场上任意数量的水属性怪兽作为祭品。这张卡的祭品召唤成功时，给这张卡放置作为祭品的水属性怪兽数量的雾指示物。这张卡的攻击力每有1个雾指示物上升500。
function c20003527.initial_effect(c)
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备表示在场上存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c20003527.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡祭品召唤的场合，可以只用自己场上任意数量的水属性怪兽作为祭品。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20003527,0))  --"只用水属性怪兽作为祭品召唤"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetCondition(c20003527.sumcon)
	e3:SetOperation(c20003527.sumop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	-- 这张卡的祭品召唤成功时，给这张卡放置作为祭品的水属性怪兽数量的雾指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c20003527.valcheck)
	c:RegisterEffect(e4)
	-- 这张卡的祭品召唤成功时，给这张卡放置作为祭品的水属性怪兽数量的雾指示物。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(20003527,1))  --"放置指示物"
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCondition(c20003527.addcon)
	e5:SetOperation(c20003527.addc)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 这张卡的攻击力每有1个雾指示物上升500。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetValue(c20003527.atkval)
	c:RegisterEffect(e6)
end
-- 检查卡片是否处于表侧守备表示状态。
function c20003527.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 定义过滤条件：卡片为水属性，且控制者是玩家本人或卡片为表侧表示。
function c20003527.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否满足上级召唤条件（等级5以上且存在足够数量的水属性祭品）。
function c20003527.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	-- 获取场上所有满足水属性过滤条件的卡片组。
	local mg=Duel.GetMatchingGroup(c20003527.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查怪兽等级是否在5以上，并检查是否存在足够数量的祭品。
	return c:IsLevelAbove(5) and Duel.CheckTribute(c,min,10,mg)
end
-- 执行上级召唤的祭品选择和解放操作。
function c20003527.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	-- 获取场上所有满足水属性过滤条件的卡片组。
	local mg=Duel.GetMatchingGroup(c20003527.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 玩家选择指定数量的水属性怪兽作为祭品。
	local sg=Duel.SelectTribute(tp,c,min,10,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为召唤素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 获取召唤素材，统计其中水属性怪兽的数量并记录到Label。
function c20003527.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER))
end
-- 检查是否为上级召唤（祭品召唤）。
function c20003527.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 给这张卡放置对应数量的雾指示物。
function c20003527.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1019,e:GetLabelObject():GetLabel())
	end
end
-- 计算攻击力上升值。
function c20003527.atkval(e,c)
	-- 返回场上雾指示物数量乘以500的数值。
	return Duel.GetCounter(0,1,1,0x1019)*500
end
