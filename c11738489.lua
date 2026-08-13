--ジ・アライバル・サイバース＠イグニスター
-- 效果：
-- 属性不同的怪兽3只以上
-- ①：「电子界到临者@火灵天星」在自己场上只能有1只表侧表示存在。
-- ②：这张卡的原本攻击力变成作为这张卡的连接素材的怪兽数量×1000。
-- ③：这张卡不受其他卡的效果影响。
-- ④：1回合1次，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏，在作为这张卡所连接区的自己场上把1只「@火灵天星衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
function c11738489.initial_effect(c)
	c:SetUniqueOnField(1,0,11738489)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用3~6只满足条件（属性各不相同）的怪兽作为连接素材。
	aux.AddLinkProcedure(c,nil,3,6,c11738489.lcheck)
	-- ②：这张卡的原本攻击力变成作为这张卡的连接素材的怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c11738489.matcheck)
	c:RegisterEffect(e1)
	-- ③：这张卡不受其他卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c11738489.efilter)
	c:RegisterEffect(e2)
	-- ④：1回合1次，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏，在作为这张卡所连接区的自己场上把1只「@火灵天星衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c11738489.destg)
	e3:SetOperation(c11738489.desop)
	c:RegisterEffect(e3)
end
-- 判定连接素材是否满足“属性各不相同”的条件：素材中不同属性的种类数等于素材总数，即每种属性只出现一次。
function c11738489.lcheck(g)
	return g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
-- 素材检查效果：当这张卡作为连接素材被使用后，读取素材数量ct，为这张卡注册一个“原本攻击力变为ct×1000”的永续效果。
function c11738489.matcheck(e,c)
	local ct=c:GetMaterialCount()
	-- ②：这张卡的原本攻击力变成作为这张卡的连接素材的怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ct*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 免疫判定函数：当试图作用于这张卡的效果的持有者不是这张卡的持有者时，返回true，即不受其他卡的效果影响。
function c11738489.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 选择对象的过滤器：若连接区有可用空格，则场上任意怪兽可选；若无空格，则只能选择本卡所连接区的我方怪兽（通过破坏腾出格子后特招衍生物）。
function c11738489.cfilter(c,g,ct)
	return (c:IsType(TYPE_MONSTER) and ct~=0) or (ct==0 and g:IsContains(c))
end
-- ④效果的发动条件与目标选择：计算连接区可用空格数及本卡所连接区的我方怪兽；确认场上存在可选目标且能特殊召唤衍生物；选定目标后设置破坏、特殊召唤、衍生物的操作信息。
function c11738489.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 计算本卡连接区（仅主怪兽区）内玩家tp可用的空格数量，用于判断破坏后是否有位置特殊召唤衍生物。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	local lg=c:GetLinkedGroup():Filter(Card.IsControler,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11738489.cfilter(chkc,lg,ct) and chkc~=c end
	-- 发动条件检查：确认场上存在至少1只满足cfilter条件的怪兽（不能选择本卡），可作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(c11738489.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,lg,ct)
		-- 同时确认玩家tp可以在指定连接区zone特殊召唤「@火灵天星衍生物」，满足后才能发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0x135,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp,0,zone) end
	-- 向玩家显示选择提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1只满足条件的怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c11738489.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,lg,ct)
	-- 设置操作信息：本次连锁包含破坏所选择的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次连锁包含特殊召唤，数量为1（衍生物）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：本次连锁包含衍生物特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ④效果处理时：若对象仍与效果关联且被成功破坏，则在该卡连接区特殊召唤1只「@火灵天星衍生物」。
function c11738489.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与该效果关联（未离场等），然后将其破坏；若破坏成功则继续处理后续特招。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if not c:IsRelateToEffect(e) then return end
		local zone=bit.band(c:GetLinkedZone(tp),0x1f)
		-- 特殊召唤衍生物前再次确认玩家tp可以在连接区zone特殊召唤该衍生物（防止格子或限制变化）。
		if Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0x135,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp,0,zone) then
			-- 创建1只「@火灵天星衍生物」（卡号11738490）的衍生物。
			local token=Duel.CreateToken(tp,11738490)
			-- 以表侧表示将衍生物特殊召唤到玩家tp场上的指定连接区zone。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end
