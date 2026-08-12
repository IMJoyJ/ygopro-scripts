--ガーディアン・エルマ
-- 效果：
-- 当自己场上存在「蝶之短剑-回音」时才能召唤·反转召唤·特殊召唤。这张卡召唤·特殊召唤成功时，可以从自己的墓地里选择1张装备魔法卡装备在这张卡身上。
function c74367458.initial_effect(c)
	-- 当自己场上存在「蝶之短剑-回音」时才能召唤·反转召唤……
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c74367458.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- ……特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c74367458.sumlimit)
	c:RegisterEffect(e3)
	-- 这张卡召唤·特殊召唤成功时，可以从自己的墓地里选择1张装备魔法卡装备在这张卡身上。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74367458,0))  --"装备"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c74367458.eqtg)
	e4:SetOperation(c74367458.eqop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 过滤函数：检查卡片是否为表侧表示的「蝶之短剑-回音」
function c74367458.cfilter(c)
	return c:IsFaceup() and c:IsCode(69243953)
end
-- 召唤·反转召唤限制的条件函数：自己场上不存在「蝶之短剑-回音」时，不能召唤·反转召唤
function c74367458.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「蝶之短剑-回音」
	return not Duel.IsExistingMatchingCard(c74367458.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤限制的条件函数：只有在自己场上存在「蝶之短剑-回音」时才能特殊召唤
function c74367458.sumlimit(e,se,sp,st,pos,tp)
	-- 检查特殊召唤时自己场上是否存在表侧表示的「蝶之短剑-回音」
	return Duel.IsExistingMatchingCard(c74367458.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：检查卡片是否为可以装备给当前怪兽的装备魔法卡
function c74367458.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 效果的发动准备与目标选择函数：检查魔法与陷阱区域空位及墓地中是否存在可装备的装备魔法卡，并选择对象
function c74367458.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74367458.filter(chkc,e:GetHandler()) end
	-- 在效果发动阶段，检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 在效果发动阶段，检查自己墓地是否存在可以装备给这张卡的装备魔法卡
		and Duel.IsExistingTarget(c74367458.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 给玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地中1张符合条件的装备魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,c74367458.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 设置当前连锁的操作信息，表示该效果包含“卡片离开墓地”的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果的实际处理函数：将选择的装备魔法卡装备给这张卡
function c74367458.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的作为效果对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的装备魔法卡作为装备卡装备给这张卡
		Duel.Equip(tp,tc,c)
	end
end
