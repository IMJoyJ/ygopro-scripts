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
	-- 作为祭品的水属性怪兽数量
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
c20003527.mentioned_counter={
	[0x1019]=true,
}
-- 判断自身是否以表侧守备表示在场上存在，是则满足自我破坏的条件
function c20003527.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤可作为祭品的卡：是水属性怪兽，且是自己的怪兽或是表侧表示的怪兽
function c20003527.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断祭品召唤条件是否满足：这张卡是5星以上，且场上存在最少数量至最多10个可作为祭品的怪兽
function c20003527.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	-- 检索双方场上所有满足条件的水属性怪兽作为候选祭品组
	local mg=Duel.GetMatchingGroup(c20003527.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断这张卡是5星以上，且候选祭品组中存在足够数量（最少min个、最多10个）的祭品，条件成立则可以用水属性怪兽作为祭品召唤
	return c:IsLevelAbove(5) and Duel.CheckTribute(c,min,10,mg)
end
-- 执行祭品召唤的处理：确定祭品数量下限，检索候选的水属性怪兽，让玩家选择祭品，将所选怪兽设为召唤素材并解放
function c20003527.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	-- 检索双方场上所有满足条件的水属性怪兽作为候选祭品组
	local mg=Duel.GetMatchingGroup(c20003527.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从候选祭品组中选择min到10个怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,min,10,mg)
	c:SetMaterial(sg)
	-- 以召唤素材的原因解放所选的一组怪兽，作为这张卡的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查这张卡的召唤素材，统计其中水属性怪兽的数量并记录到标签中，供放置指示物效果使用
function c20003527.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER))
end
-- 判断这张卡是否为祭品召唤（上级召唤）成功，作为放置指示物效果的发动条件
function c20003527.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 这张卡祭品召唤成功时，若这张卡仍与效果关联，则按素材检查效果记录的水属性怪兽数量给这张卡放置雾指示物
function c20003527.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1019,e:GetLabelObject():GetLabel())
	end
end
-- 计算攻击力上升值：场上雾指示物的数量乘以500
function c20003527.atkval(e,c)
	-- 返回场上雾指示物数量乘以500的数值，作为这张卡攻击力的上升值
	return Duel.GetCounter(0,1,1,0x1019)*500
end
