--双天の獅使－阿吽
-- 效果：
-- 「双天」怪兽×2
-- ①：这张卡得到作为融合素材的怪兽的原本卡名的以下效果。
-- ●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。
-- ●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
-- ②：融合召唤的这张卡被破坏的场合才能发动。从卡组把「双天拳之熊罴」「双天脚之鸿鹄」各1只特殊召唤。那些怪兽在这个回合不会被战斗·效果破坏。
function c28798938.initial_effect(c)
	-- 记录这张卡的效果文本上记载了「双天将 金刚」「双天将 密迹」「双天拳之熊罴」「双天脚之鸿鹄」4张卡的卡名。
	aux.AddCodeList(c,33026283,284224,85360035,11759079)
	c:EnableReviveLimit()
	-- 为这张卡设置融合召唤手续：需要2只「双天」怪兽作为融合素材，且允许以非正规融合方式召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true)
	-- ①：这张卡得到作为融合素材的怪兽的原本卡名的以下效果。●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c28798938.regcon)
	e0:SetOperation(c28798938.regop)
	c:RegisterEffect(e0)
	-- ②：融合召唤的这张卡被破坏的场合才能发动。从卡组把「双天拳之熊罴」「双天脚之鸿鹄」各1只特殊召唤。那些怪兽在这个回合不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c28798938.spcon)
	e3:SetTarget(c28798938.sptg)
	e3:SetOperation(c28798938.spop)
	c:RegisterEffect(e3)
end
-- 融合素材效果赋予的触发条件函数：判断这张卡是否是通过融合召唤特殊召唤成功的。
function c28798938.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时的不入连锁处理函数：读取融合素材，若含效果怪兽则注册标记，若含原本卡名为「双天将 金刚」或「双天将 密迹」的怪兽则分别赋予对应效果并添加客户端提示。
function c28798938.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g==0 then return end
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	if g:IsExists(Card.IsOriginalCodeRule,1,nil,33026283) then
		-- ●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetCondition(c28798938.atkcon)
		e1:SetTarget(c28798938.atktg)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,0))  --"「双天将 金刚」为融合素材"
	end
	if g:IsExists(Card.IsOriginalCodeRule,1,nil,284224) then
		-- ●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(28798938,2))
		e2:SetCategory(CATEGORY_REMOVE)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_MZONE)
		e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e2:SetCountLimit(1)
		e2:SetCondition(c28798938.rmcon)
		e2:SetTarget(c28798938.rmtg)
		e2:SetOperation(c28798938.rmop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,1))  --"「双天将 密迹」为融合素材"
	end
end
-- 攻击力变为3000效果的适用条件函数：确认当前处于伤害计算阶段且自己正在进行战斗的怪兽属于「双天」字段。
function c28798938.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取自己正在进行战斗的怪兽。
	local a=Duel.GetBattleMonster(tp)
	-- 判断当前是否为伤害计算时，且自己正在战斗的怪兽存在并属于「双天」(0x14f)字段。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and a and a:IsSetCard(0x14f)
end
-- 攻击力变为3000效果的对象筛选函数：仅对当前自己正在进行战斗的那只怪兽适用攻击力变化。
function c28798938.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取自己正在进行战斗的怪兽。
	local a=Duel.GetBattleMonster(tp)
	return c==a
end
-- 除外效果的发动条件函数：判断当前回合玩家是否为对方。
function c28798938.rmcon(e)
	-- 判断当前回合玩家不等于效果持有者的控制者（即处于对方回合）。
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 除外效果的目标检查与选择函数：确认场上存在可除外的卡，让玩家选择场上1张卡作为对象并登记除外操作信息。
function c28798938.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 在检查能否发动时，确认双方场上存在至少1张可以除外且能成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择要除外卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可以除外的卡作为当前连锁的发动对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 向引擎登记本次连锁确定将对象卡除外（1张）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的处理函数：若对象卡仍与效果保持联系，则将其表侧表示除外。
function c28798938.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数：检查被破坏的这张卡破坏前位于怪兽区且是通过融合召唤出场的。
function c28798938.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义特殊召唤过滤函数，检查卡组中的怪兽是否为「双天拳之熊罴」或「双天脚之鸿鹄」且能正规特殊召唤。
function c28798938.spfilter(c,e,tp)
	return c:IsCode(85360035,11759079) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动检查与信息登记函数：验证己方怪兽区有至少2个空位、未受同时特召限制且卡组存在卡名不同的2只目标怪兽，并登记卡组特召2只的操作信息。
function c28798938.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上主要怪兽区域的可用空格数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 从自己卡组检索所有符合特殊召唤条件的「双天拳之熊罴」和「双天脚之鸿鹄」。
		local g=Duel.GetMatchingGroup(c28798938.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检查检索到的卡片组中是否存在2张卡名互不相同的子集（即各1只）。
		return g:CheckSubGroup(aux.dncheck,2,2)
	end
	-- 向引擎登记本次连锁预计从自己卡组特殊召唤2只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果的处理函数：确认空位与特召数量限制后，从卡组选「双天拳之熊罴」「双天脚之鸿鹄」各1只特殊召唤，并赋予它们直到回合结束不会被战斗·效果破坏的永续效果。
function c28798938.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的当前可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取自己卡组中所有满足条件的「双天拳之熊罴」和「双天脚之鸿鹄」。
	local g=Duel.GetMatchingGroup(c28798938.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 向玩家发送选择要特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组符合条件的怪兽中选择2只卡名互不相同的怪兽（各1只）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if not sg then return end
	local tc=sg:GetFirst()
	-- 遍历玩家选中的2只待特殊召唤的怪兽。
	for tc in aux.Next(sg) do
		-- 执行单只怪兽的分解特殊召唤步骤以表侧表示出场，若成功则为其赋予抗破坏效果。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 那些怪兽在这个回合不会被战斗·效果破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些怪兽在这个回合不会被战斗·效果破坏。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,3))  --"「双天之狮使-阿吽」效果适用中"
		end
	end
	-- 完成分解的特殊召唤流程，使此前通过SpecialSummonStep出场的怪兽正式同时特殊召唤到场上。
	Duel.SpecialSummonComplete()
end
