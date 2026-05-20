--甲虫装機 ダンセル
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「甲虫装机」怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡在自己场上存在，给这张卡装备的卡被送去自己墓地的场合才能发动。从卡组把「甲虫装机 豆娘」以外的1只「甲虫装机」怪兽特殊召唤。
-- ③：把这张卡当作装备卡使用来装备的怪兽的等级上升3星。
function c68184115.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「甲虫装机」怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68184115,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c68184115.eqtg)
	e1:SetOperation(c68184115.eqop)
	c:RegisterEffect(e1)
	-- ③：把这张卡当作装备卡使用来装备的怪兽的等级上升3星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(3)
	c:RegisterEffect(e2)
	-- ②：这张卡在自己场上存在，给这张卡装备的卡被送去自己墓地的场合才能发动。从卡组把「甲虫装机 豆娘」以外的1只「甲虫装机」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68184115,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c68184115.spcon)
	e3:SetTarget(c68184115.sptg)
	e3:SetOperation(c68184115.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡·墓地中可以装备的「甲虫装机」怪兽
function c68184115.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果①的发动准备与合法性检查
function c68184115.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的手卡或墓地是否存在满足过滤条件的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c68184115.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：涉及从墓地移出卡片
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果①的效果处理
function c68184115.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔陷区是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手卡或墓地选择1只满足条件的「甲虫装机」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c68184115.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c68184115.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 限制装备卡只能装备给当前效果的发动者（即这张卡）
function c68184115.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤条件：送去自己墓地的、原本装备在当前卡片上的装备卡
function c68184115.cfilter(c,ec,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetEquipTarget()==ec
end
-- 效果②的发动条件：给这张卡装备的卡被送去自己墓地
function c68184115.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c68184115.cfilter,1,nil,e:GetHandler(),tp)
end
-- 过滤条件：卡组中「甲虫装机 豆娘」以外的、可以特殊召唤的「甲虫装机」怪兽
function c68184115.spfilter(c,e,tp)
	return c:IsSetCard(0x56) and not c:IsCode(68184115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查
function c68184115.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFaceup()
		-- 检查自己场上的怪兽区是否有空位，且卡组中是否存在可特殊召唤的「甲虫装机」怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c68184115.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理
function c68184115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「甲虫装机 豆娘」以外的「甲虫装机」怪兽
	local g=Duel.SelectMatchingCard(tp,c68184115.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
