--轟雷帝ザボルグ
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤的场合，以场上1只怪兽为对象发动。那只怪兽破坏。破坏的怪兽是光属性的场合，双方各自从自身的额外卡组把最多有那个原本的等级·阶级数量的卡尽可能送去墓地（这张卡把光属性怪兽解放作上级召唤的场合，送去墓地的对方的卡由自己来选）。
function c87602890.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87602890,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c87602890.otcon)
	e1:SetOperation(c87602890.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤的场合，以场上1只怪兽为对象发动。那只怪兽破坏。破坏的怪兽是光属性的场合，双方各自从自身的额外卡组把最多有那个原本的等级·阶级数量的卡尽可能送去墓地（这张卡把光属性怪兽解放作上级召唤的场合，送去墓地的对方的卡由自己来选）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87602890,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c87602890.condition)
	e3:SetTarget(c87602890.target)
	e3:SetOperation(c87602890.operation)
	c:RegisterEffect(e3)
	-- （这张卡把光属性怪兽解放作上级召唤的场合，送去墓地的对方的卡由自己来选）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c87602890.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤场上上级召唤的怪兽
function c87602890.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 检查是否满足“把1只上级召唤的怪兽解放作上级召唤”的特殊召唤条件
function c87602890.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有的上级召唤的怪兽
	local mg=Duel.GetMatchingGroup(c87602890.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查自身等级是否在7星以上、所需祭品数是否不大于1，且场上是否存在可解放的上级召唤怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行“把1只上级召唤的怪兽解放作上级召唤”的解放操作
function c87602890.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有的上级召唤的怪兽作为解放候选
	local mg=Duel.GetMatchingGroup(c87602890.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家选择1只上级召唤的怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽进行上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 触发条件：此卡上级召唤成功
function c87602890.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动时的对象选择与操作信息注册
function c87602890.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为“破坏选中的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏对象怪兽，若其为光属性则双方将额外卡组的卡送去墓地
function c87602890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的破坏对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏该怪兽，若破坏失败或该怪兽在场上时不是光属性，则结束效果处理
		if Duel.Destroy(tc,REASON_EFFECT)==0 or bit.band(tc:GetPreviousAttributeOnField(),ATTRIBUTE_LIGHT)==0 then return end
		local lv=tc:GetOriginalLevel()
		if tc:IsType(TYPE_XYZ) then
			lv=tc:GetOriginalRank()
		end
		-- 提示自己选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 自己从自身的额外卡组选择等同于被破坏怪兽原本等级/阶级数量的卡
		local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_EXTRA,0,lv,lv,nil)
		-- 获取对方额外卡组的所有卡
		local tg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		if e:GetLabel()==1 then
			-- 让玩家确认对方额外卡组的卡
			Duel.ConfirmCards(tp,tg)
			-- 提示自己选择对方要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local g2=tg:Select(tp,lv,lv,nil)
			g1:Merge(g2)
		else
			-- 提示对方选择自身要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local g2=tg:Select(1-tp,lv,lv,nil)
			g1:Merge(g2)
		end
		if g1:GetCount()>0 then
			-- 中断当前效果，使后续的送去墓地处理不与破坏同时进行
			Duel.BreakEffect()
			-- 将双方选中的额外卡组的卡送去墓地
			Duel.SendtoGrave(g1,REASON_EFFECT)
		end
		if e:GetLabel()==1 then
			-- 洗切对方的额外卡组
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- 检查上级召唤的祭品中是否存在光属性怪兽，并为效果3设置对应的Label标记
function c87602890.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
