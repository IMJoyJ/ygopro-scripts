--ZS－双頭龍賢者
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己墓地选1只光属性以外的「No.」怪兽效果无效特殊召唤，从自己场上把这张卡和1只「希望皇 霍普」怪兽各当作攻击力上升1700的装备卡使用给那只特殊召唤的怪兽装备。这个回合，自己只能有1次攻击宣言。
-- ②：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击宣言时才能发动。那只攻击怪兽攻击力变成2倍并在结束阶段破坏。
function c32281491.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己墓地选1只光属性以外的「No.」怪兽效果无效特殊召唤，从自己场上把这张卡和1只「希望皇 霍普」怪兽各当作攻击力上升1700的装备卡使用给那只特殊召唤的怪兽装备。这个回合，自己只能有1次攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32281491,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c32281491.sptg)
	e1:SetOperation(c32281491.spop)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击宣言时才能发动。那只攻击怪兽攻击力变成2倍并在结束阶段破坏。
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
-- 定义特殊召唤的筛选条件：目标需不是光属性、属于「No.」字段且能够被特殊召唤。
function c32281491.spfilter(c,e,tp)
	return c:IsNonAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义装备卡素材的筛选条件：目标需是表侧表示且属于「希望皇 霍普」字段。
function c32281491.eqfilter(c)
	return c:IsSetCard(0x107f) and c:IsFaceup()
end
-- 效果①发动时的合法性检查：主要怪兽区有空格、魔陷区至少2个空格、墓地有符合条件的目标、场上有符合条件的「希望皇 霍普」怪兽。
function c32281491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔陷区（含场地魔法区域）是否至少有2个空格，用于容纳作为装备卡的2张卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 检查墓地中是否存在至少1只满足spfilter的「No.」怪兽（非光且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c32281491.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上是否存在至少1只满足eqfilter的表侧「希望皇 霍普」怪兽。
		and Duel.IsExistingMatchingCard(c32281491.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：本效果将进行1次从墓地特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：本效果将进行1次装备卡装备操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE)
end
-- 效果①处理：从墓地选择符合条件的「No.」怪兽特殊召唤并使其效果无效，再将这张卡与场上的「希望皇 霍普」怪兽作为装备卡装备给它，同时设置本回合1次攻击宣言的限制。
function c32281491.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出卡片选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地筛选出符合条件的「No.」怪兽，并用王家长眠之谷过滤后选择1张。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32281491.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧表示进行特殊召唤（分解步骤），若成功则继续处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效（使其效果无效化）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 若魔陷区空格少于2个、这张卡已不与效果关联或处于里侧表示，则无法进行装备，终止后续处理。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 弹出卡片选择提示，提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己场上选择1只表侧表示的「希望皇 霍普」怪兽作为装备卡（排除已特殊召唤的怪兽）。
		local sg=Duel.SelectMatchingCard(tp,c32281491.eqfilter,tp,LOCATION_MZONE,0,1,1,tc)
		local ec=sg:GetFirst()
		if ec then
			c32281491.zs_equip_monster(c,c,tp,tc)
			c32281491.zs_equip_monster(c,ec,tp,tc)
			c:RegisterFlagEffect(32281491,RESET_EVENT+RESETS_STANDARD,1,0)
		end
	end
	-- 完成特殊召唤的分解处理，确认特殊召唤成功。
	Duel.SpecialSummonComplete()
	-- 这个回合，自己只能有1次攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c32281491.atklimitcon)
	e3:SetTarget(c32281491.atklimittg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击限制效果e3注册到场上，持续到结束阶段。
	Duel.RegisterEffect(e3,tp)
	-- 从自己场上把这张卡和1只「希望皇 霍普」怪兽各当作攻击力上升1700的装备卡使用给那只特殊召唤的怪兽装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(c32281491.checkop)
	e4:SetLabelObject(e3)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册e4，用于监听攻击宣言并记录已进行攻击的怪兽，配合攻击限制效果。
	Duel.RegisterEffect(e4,tp)
end
-- 定义装备处理函数：将怪兽ec作为装备卡装备给tc，并附加攻击力上升1700和装备对象限制。
function c32281491.zs_equip_monster(c,ec,tp,tc)
	-- 尝试将ec装备给tc；如果装备失败则直接退出该函数。
	if not Duel.Equip(tp,ec,tc) then return end
	-- 当作装备卡使用给那只特殊召唤的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c32281491.eqlimit)
	e1:SetLabelObject(tc)
	ec:RegisterEffect(e1)
	-- 攻击力上升1700
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1700)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e2)
end
-- 装备限制的判定：只允许装备给效果指定的那只特殊召唤怪兽。
function c32281491.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击限制效果的发动条件：已发生过一次攻击宣言（标签值不为0）。
function c32281491.atklimitcon(e)
	return e:GetLabel()~=0
end
-- 攻击限制的目标判定：除已攻击过的那只怪兽外，其他怪兽不能进行攻击宣言。
function c32281491.atklimittg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 记录每次攻击宣言的怪兽的FieldID，并写入攻击限制效果的标签。
function c32281491.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end
-- 效果②的发动条件：这张卡作为装备卡且带有①的标记，并且攻击宣言的怪兽是这张卡的装备对象。
function c32281491.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(32281491)~=0
		-- 确认攻击宣言的怪兽正是这张卡装备的怪兽。
		and Duel.GetAttacker()==c:GetEquipTarget()
end
-- 效果②处理：将攻击怪兽的攻击力变成2倍，并在结束阶段将其破坏。
function c32281491.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc:IsImmuneToEffect(e) then return end
	-- 那只攻击怪兽攻击力变成2倍
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(tc:GetAttack()*2)
	tc:RegisterEffect(e1)
	local fid=e:GetHandler():GetFieldID()
	tc:RegisterFlagEffect(32281491,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 并在结束阶段破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(tc)
	e2:SetCondition(c32281491.descon)
	e2:SetOperation(c32281491.desop)
	-- 注册到结束阶段执行的破坏效果。
	Duel.RegisterEffect(e2,tp)
end
-- 破坏效果的发动条件：怪兽仍带有本次攻击力翻倍时记录的标记则执行；否则重置该效果。
function c32281491.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(32281491)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏效果的执行：将那只攻击怪兽破坏。
function c32281491.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 用效果破坏该怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
