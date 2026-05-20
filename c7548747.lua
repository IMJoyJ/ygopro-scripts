--大いなる魔導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从自己的额外卡组·场上·墓地选1只4星以外的「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。自己墓地有「大贤者」融合·同调·超量·连接怪兽各1只以上存在的场合，也能从「大贤者」怪兽以外的额外卡组的融合·同调·超量·连接怪兽中选这个效果装备的怪兽。
function c7548747.initial_effect(c)
	-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从自己的额外卡组·场上·墓地选1只4星以外的「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。自己墓地有「大贤者」融合·同调·超量·连接怪兽各1只以上存在的场合，也能从「大贤者」怪兽以外的额外卡组的融合·同调·超量·连接怪兽中选这个效果装备的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,7548747+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c7548747.target)
	e1:SetOperation(c7548747.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选自己场上可以装备卡片的「大贤者」怪兽
function c7548747.filter(c,tp,check)
	-- 检查卡片是否表侧表示、属于「大贤者」系列，且额外卡组、场上或墓地存在至少1张符合装备条件的卡
	return c:IsFaceup() and c:IsSetCard(0x150) and Duel.IsExistingMatchingCard(c7548747.eqfilter,tp,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,1,c,check)
end
-- 定义过滤函数：筛选符合装备条件的怪兽（4星以外的「大贤者」怪兽，或在满足墓地条件时，额外卡组的「大贤者」以外的融合/同调/超量/连接怪兽）
function c7548747.eqfilter(c,check)
	return (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and not c:IsLevel(4)
		or check and c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x150) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 定义过滤函数：筛选墓地中特定卡片类型的「大贤者」怪兽
function c7548747.gfilter(c,type)
	return c:IsSetCard(0x150) and c:IsType(type)
end
-- 定义检查函数：检查墓地中是否存在特定卡片类型的「大贤者」怪兽
function c7548747.check(tp,type)
	-- 检查自己墓地是否存在至少1张指定卡片类型的「大贤者」怪兽
	return Duel.IsExistingMatchingCard(c7548747.gfilter,tp,LOCATION_GRAVE,0,1,nil,type)
end
-- 定义效果的发动准备与合法性检查
function c7548747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local check=c7548747.check(tp,TYPE_FUSION) and c7548747.check(tp,TYPE_SYNCHRO) and c7548747.check(tp,TYPE_XYZ) and c7548747.check(tp,TYPE_LINK)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7548747.filter(chkc,tp,check) end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取自己魔陷区的可用格子数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chk==0 then return ft>0
		-- 检查自己场上是否存在可以作为对象的、且有可用装备卡的「大贤者」怪兽
		and Duel.IsExistingTarget(c7548747.filter,tp,LOCATION_MZONE,0,1,nil,tp,check) end
	-- 设置选择卡片时的提示信息为“请选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只符合条件的「大贤者」怪兽作为效果的对象
	Duel.SelectTarget(tp,c7548747.filter,tp,LOCATION_MZONE,0,1,1,nil,tp,check)
end
-- 定义效果的处理逻辑
function c7548747.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍在场上表侧表示存在，且自己魔陷区有空余的格子
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local check=c7548747.check(tp,TYPE_FUSION) and c7548747.check(tp,TYPE_SYNCHRO) and c7548747.check(tp,TYPE_XYZ) and c7548747.check(tp,TYPE_LINK)
		-- 设置选择卡片时的提示信息为“请选择要装备的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从额外卡组、场上或墓地选择1只满足条件的怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c7548747.eqfilter),tp,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc,check)
		local ec=g:GetFirst()
		if ec then
			-- 将选中的怪兽作为装备卡装备给对象怪兽，若装备失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 当作装备卡使用给作为对象的怪兽装备
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(c7548747.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 定义装备限制：该卡只能装备给作为对象的怪兽
function c7548747.eqlimit(e,c)
	return c==e:GetLabelObject()
end
