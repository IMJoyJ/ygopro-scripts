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
	-- 添加连接召唤手续，要求使用3到6个连接素材，且素材怪兽属性各不相同
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
-- 连接素材属性检查函数，确保连接素材的属性各不相同
function c11738489.lcheck(g)
	return g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
-- 材质检查函数，用于设置卡牌原本攻击力
function c11738489.matcheck(e,c)
	local ct=c:GetMaterialCount()
	-- 设置自身原本攻击力为连接素材数量乘以1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ct*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 效果免疫过滤函数，使该卡不受其他卡的效果影响
function c11738489.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 目标选择过滤函数，用于判断目标怪兽是否满足破坏条件
function c11738489.cfilter(c,g,ct)
	return (c:IsType(TYPE_MONSTER) and ct~=0) or (ct==0 and g:IsContains(c))
end
-- 效果发动时的目标选择函数
function c11738489.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 获取连接区可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	local lg=c:GetLinkedGroup():Filter(Card.IsControler,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11738489.cfilter(chkc,lg,ct) and chkc~=c end
	-- 判断是否满足发动条件，存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c11738489.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,lg,ct)
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0x135,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp,0,zone) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c11738489.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,lg,ct)
	-- 设置操作信息，记录将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，记录将要特殊召唤的衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息，记录将要生成的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果处理函数，执行破坏与特殊召唤操作
function c11738489.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽存在且成功破坏，则继续处理特殊召唤
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if not c:IsRelateToEffect(e) then return end
		local zone=bit.band(c:GetLinkedZone(tp),0x1f)
		-- 判断是否可以特殊召唤衍生物
		if Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0x135,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp,0,zone) then
			-- 创建一张衍生物卡片
			local token=Duel.CreateToken(tp,11738490)
			-- 将衍生物特殊召唤到场上
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end
