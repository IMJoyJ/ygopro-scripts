--ヴァイロン・アルファ
-- 效果：
-- 名字带有「大日」的调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，可以选择自己墓地存在的1张装备魔法卡给这张卡装备。有装备卡装备的这张卡不会被装备卡以外的魔法·陷阱卡的效果破坏。
function c56768355.initial_effect(c)
	-- 添加同调召唤手续：名字带有「大日」的调整 + 调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x30),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，可以选择自己墓地存在的1张装备魔法卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56768355,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c56768355.eqcon)
	e1:SetTarget(c56768355.eqtg)
	e1:SetOperation(c56768355.eqop)
	c:RegisterEffect(e1)
	-- 有装备卡装备的这张卡不会被装备卡以外的魔法·陷阱卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c56768355.indcon)
	e2:SetValue(c56768355.indval)
	c:RegisterEffect(e2)
end
-- 判定效果发动条件：此卡同调召唤成功
function c56768355.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：自己墓地中可以装备给此卡的装备魔法卡
function c56768355.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 判定是否满足发动条件，并选择自己墓地的1张装备魔法卡作为效果对象
function c56768355.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56768355.filter(chkc,e:GetHandler()) end
	-- 判定自身魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己墓地是否存在至少1张可以装备给此卡的装备魔法卡
		and Duel.IsExistingTarget(c56768355.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1张符合条件的装备魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c56768355.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 设置操作信息：包含卡片离开墓地的分类
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：将选择的墓地装备魔法卡装备给此卡
function c56768355.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片作为装备卡装备给此卡
		Duel.Equip(tp,tc,c)
	end
end
-- 判定抗性效果的适用条件：此卡当前有装备卡装备
function c56768355.indcon(e)
	return e:GetHandler():GetEquipCount()>0
end
-- 判定抗性效果的适用范围：不会被装备卡以外的魔法·陷阱卡的效果破坏
function c56768355.indval(e,re)
	if not re then return false end
	local ty=re:GetActiveType()
	return bit.band(ty,TYPE_SPELL+TYPE_TRAP)~=0 and bit.band(ty,TYPE_EQUIP)==0
end
