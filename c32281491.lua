--ZS－双頭龍賢者
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己墓地选1只光属性以外的「No.」怪兽效果无效特殊召唤，从自己场上把这张卡和1只「希望皇 霍普」怪兽各当作攻击力上升1700的装备卡使用给那只特殊召唤的怪兽装备。这个回合，自己只能有1次攻击宣言。
-- ②：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击宣言时才能发动。那只攻击怪兽攻击力变成2倍并在结束阶段破坏。
function c32281491.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32281491,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c32281491.sptg)
	e1:SetOperation(c32281491.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：从自己墓地选1只光属性以外的「No.」怪兽效果无效特殊召唤，从自己场上把这张卡和1只「希望皇 霍普」怪兽各当作攻击力上升1700的装备卡使用给那只特殊召唤的怪兽装备。这个回合，自己只能有1次攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32281491,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c32281491.atkcon)
	e2:SetOperation(c32281491.atkop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地「No.」怪兽（光属性以外且可特殊召唤）
function c32281491.spfilter(c,e,tp)
	return c:IsNonAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索满足条件的场上「希望皇 霍普」怪兽（正面表示）
function c32281491.eqfilter(c)
	return c:IsSetCard(0x107f) and c:IsFaceup()
end
-- 判断是否满足①效果的发动条件（场地上有足够空间且存在符合条件的怪兽）
function c32281491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否有足够的魔法陷阱区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 判断墓地中是否存在符合条件的「No.」怪兽
		and Duel.IsExistingMatchingCard(c32281491.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断场上是否存在符合条件的「希望皇 霍普」怪兽
		and Duel.IsExistingMatchingCard(c32281491.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：特殊召唤目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：装备目标
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE)
end
-- 效果作用：选择并特殊召唤符合条件的怪兽，将其效果无效化并装备给目标怪兽，同时设置本回合只能攻击一次
function c32281491.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32281491.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：那只特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：那只特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 判断是否满足装备条件（魔法陷阱区域不足或装备卡不在场）
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 提示玩家选择要装备的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择满足条件的场上怪兽进行装备
		local sg=Duel.SelectMatchingCard(tp,c32281491.eqfilter,tp,LOCATION_MZONE,0,1,1,tc)
		local ec=sg:GetFirst()
		if ec then
			c32281491.zs_equip_monster(c,c,tp,tc)
			c32281491.zs_equip_monster(c,ec,tp,tc)
			c:RegisterFlagEffect(32281491,RESET_EVENT+RESETS_STANDARD,1,0)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 效果原文内容：这个回合，自己只能有1次攻击宣言
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c32281491.atklimitcon)
	e3:SetTarget(c32281491.atklimittg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册攻击限制效果
	Duel.RegisterEffect(e3,tp)
	-- 效果作用：设置攻击宣言时检查装备怪兽是否为指定目标
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(c32281491.checkop)
	e4:SetLabelObject(e3)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册攻击宣言检查效果
	Duel.RegisterEffect(e4,tp)
end
-- 效果作用：将装备卡装备给目标怪兽并设置攻击力加成
function c32281491.zs_equip_monster(c,ec,tp,tc)
	-- 判断装备是否成功
	if not Duel.Equip(tp,ec,tc) then return end
	-- 效果原文内容：各当作攻击力上升1700的装备卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c32281491.eqlimit)
	e1:SetLabelObject(tc)
	ec:RegisterEffect(e1)
	-- 效果原文内容：各当作攻击力上升1700的装备卡使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1700)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e2)
end
-- 装备限制条件：只能装备给指定怪兽
function c32281491.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击限制条件：判断是否已发动过攻击
function c32281491.atklimitcon(e)
	return e:GetLabel()~=0
end
-- 攻击限制目标：排除指定怪兽
function c32281491.atklimittg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 效果作用：记录攻击怪兽的FieldID
function c32281491.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end
-- 效果原文内容：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击宣言时才能发动
function c32281491.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(32281491)~=0
		-- 判断攻击怪兽是否为装备怪兽
		and Duel.GetAttacker()==c:GetEquipTarget()
end
-- 效果作用：使攻击怪兽攻击力翻倍并在结束阶段破坏
function c32281491.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc:IsImmuneToEffect(e) then return end
	-- 效果原文内容：那只攻击怪兽攻击力变成2倍
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(tc:GetAttack()*2)
	tc:RegisterEffect(e1)
	local fid=e:GetHandler():GetFieldID()
	tc:RegisterFlagEffect(32281491,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 效果原文内容：并在结束阶段破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(tc)
	e2:SetCondition(c32281491.descon)
	e2:SetOperation(c32281491.desop)
	-- 注册攻击力变化和破坏效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否满足破坏条件
function c32281491.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(32281491)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 效果作用：破坏目标怪兽
function c32281491.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 实际破坏目标怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
