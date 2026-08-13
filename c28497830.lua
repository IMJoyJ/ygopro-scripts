--GP－PB
-- 效果：
-- 「黄金荣耀-滚球手」＋「黄金荣耀」怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合才能发动（自己基本分比对方少的场合，这个效果的发动和效果不会被无效化）。把最多有那个作为融合素材的数量的对方场上的表侧表示怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-滚球手」特殊召唤。
local s,id,o=GetID()
-- 注册该卡的融合召唤限制与手续、①效果（融合召唤成功时装备对方怪兽）、辅助效果（根据LP差赋予①效果免疫）、②效果（发动过①的回合结束阶段回额外并特招滚球手）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「黄金荣耀-滚球手」和1～127只「黄金荣耀」怪兽（即1只以上）作为融合素材。
	aux.AddFusionProcCodeFunRep(c,92003832,aux.FilterBoolFunction(Card.IsFusionSetCard,0x192),1,127,true,true)
	-- ①：这张卡融合召唤的场合才能发动（自己基本分比对方少的场合，这个效果的发动和效果不会被无效化）。把最多有那个作为融合素材的数量的对方场上的表侧表示怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- （自己基本分比对方少的场合，这个效果的发动和效果不会被无效化）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(0xff)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-滚球手」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 每当场上状态调整时，根据当前LP大小动态设置①效果的属性：若本方LP少于对方，则赋予①效果“不能被无效化、不能被无效发动、可被禁止令”等抗性；否则仅保留延迟触发属性。
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	-- 判断发动方基本分是否比对方少。
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CAN_FORBIDDEN)
	else
		e1:SetProperty(EFFECT_FLAG_DELAY)
	end
end
-- 条件函数：检测这张卡是否因融合召唤而特殊召唤成功。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤条件：选择对方场上表侧表示且能变更控制权的怪兽（即可被当作装备卡装备的怪兽）。
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- ①效果的发动目标检查：计算本卡融合素材数量，确认存在魔陷区空位且对方场上有可选怪兽，以决定能否发动。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	-- 发动合法性判定：需要融合素材数量大于0且自己魔陷区有空位。
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 还需要对方场上有至少1只表侧表示且能改变控制权的怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 装备限制判定：限制这些装备卡只能装备给「黄金荣耀-弹球手」这张卡，且该卡效果有效时才允许装备。
function s.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- ①效果的发动处理：选择对方场上满足条件的怪兽（数量不超过魔陷区空位与融合素材数），将它们装备给本卡，并为每张装备卡添加装备限制效果，最后完成装备处理。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	-- 获取自己魔陷区的空格数，用于限制可装备数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 显示选择装备卡片的提示，提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从对方场上选择1～min(魔陷区空格, 融合素材数量)张表侧且可转移控制权的怪兽作为装备对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,math.min(ft,ct),nil)
	if #g==0 then return end
	-- 遍历所有选中的怪兽，准备逐一装备。
	for tc in aux.Next(g) do
		-- 尝试将当前怪兽作为装备魔法卡装备给本卡，使用分步装备模式；若成功则继续设置限制。
		if Duel.Equip(tp,tc,c,true,true) then
			-- ……把最多有那个作为融合素材的数量的对方场上的表侧表示怪兽当作装备魔法卡使用给这张卡装备。②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-滚球手」特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1,true)
		end
	end
	-- 完成所有装备操作，触发装备成功相关时点。
	Duel.EquipComplete()
end
-- ②效果的发动条件：本卡在本回合发动过①效果（通过flag标记判断）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的目标设定：将本卡返回额外卡组，并从自己的卡组·墓地特殊召唤1只「黄金荣耀-滚球手」。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记“送回额外卡组”的操作信息，目标为本卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 登记“特殊召唤”的操作信息，目标为卡组·墓地的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 特招对象的过滤函数：必须是「黄金荣耀-滚球手」且可以特殊召唤。
function s.sfilter(c,e,tp)
	return c:IsCode(92003832) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：本卡若仍与效果相关，将其送回卡组顶；成功后从卡组·墓地选择1只「黄金荣耀-滚球手」以表侧攻击表示特殊召唤。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡与效果相关，并尝试将其返回持有者卡组顶端；返回成功才继续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0
		-- 确认自己场上存在可用的怪兽区空格，确保特殊召唤可行。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择要特殊召唤的卡片的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的卡组·墓地选择1只可特殊召唤的「黄金荣耀-滚球手」，并过滤掉受王家长眠之谷影响的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的「黄金荣耀-滚球手」以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
