--剣闘獣ダリウス
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功时，以自己墓地1只「剑斗兽」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽回到持有者卡组。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 马斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c25924653.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功时，以自己墓地1只「剑斗兽」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25924653,0))  --"墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置e1的发动条件：本卡由「剑斗兽」怪兽的效果特殊召唤成功时（通过aux.gbspcon判断召唤类型）。
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c25924653.spgtg)
	e1:SetOperation(c25924653.spgop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 马斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25924653,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c25924653.spcon)
	e2:SetCost(c25924653.spcost)
	e2:SetTarget(c25924653.sptg)
	e2:SetOperation(c25924653.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡从场上离开时那只怪兽回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c25924653.leave)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
end
-- 墓地对象的过滤函数：必须为「剑斗兽」怪兽，且可以被此效果特殊召唤。
function c25924653.spgfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象指定与合法性检查：连锁对象必须是我方墓地的可特召「剑斗兽」；无连锁时需存在合法对象且我方主怪兽区有空位。
function c25924653.spgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25924653.spgfilter(chkc,e,tp) end
	-- 无连锁时的发动条件：我方主要怪兽区空位数大于0，保证能特殊召唤对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地存在1只满足spgfilter的「剑斗兽」怪兽可作为取对象的目标。
		and Duel.IsExistingTarget(c25924653.spgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方墓地选择1只满足spgfilter的「剑斗兽」怪兽设为效果对象。
	local g=Duel.SelectTarget(tp,c25924653.spgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次连锁将把对象怪兽特殊召唤（1只），供后续时点/干扰判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将取对象的墓地「剑斗兽」怪兽以表侧表示特殊召唤，使其效果无效，并与本卡建立关联，以便本卡离场时将其弹回卡组。
function c25924653.spgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的那只墓地「剑斗兽」怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与此效果关联，则将其以表侧表示特殊召唤（进入特殊召唤流程）。
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 马斗」以外的1只「剑斗兽」怪兽特殊召唤。①：这张卡从场上离开时那只怪兽回到持有者卡组。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		if c:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
			e:GetLabelObject():SetLabelObject(tc)
			c:CreateRelation(tc,RESET_EVENT+0x5020000)
			tc:CreateRelation(c,RESET_EVENT+0x5fe0000)
		end
	end
	-- 完成特殊召唤流程，使SpecialSummonStep中登记的怪兽特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
-- 离场时处理：若本卡离场且之前特殊召唤的怪兽仍与本卡存在关联，则执行返回卡组的操作。
function c25924653.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		-- 将对象怪兽以效果送回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②的发动条件：本卡在本次战斗阶段进行过战斗（存在战斗过的怪兽）。
function c25924653.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②的发动代价：将本卡自身送回持有者卡组并洗切（作为cost）。
function c25924653.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 以代价形式将本卡返回持有者卡组并洗牌。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 卡组特召的过滤函数：卡名不是「剑斗兽 马斗」、是「剑斗兽」怪兽且可被此效果特殊召唤。
function c25924653.filter(c,e,tp)
	return not c:IsCode(25924653) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的无连锁发动条件：自己的主怪兽区可用格数≥-1（发动后本卡回卡组可腾出1格），且卡组存在满足filter的「剑斗兽」怪兽。
function c25924653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 无连锁时的发动条件：自己主怪兽区空位数> -1（允许当前满场，因为cost会空出1格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 且卡组中存在至少1只满足filter的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(c25924653.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次连锁将进行从卡组特殊召唤1只「剑斗兽」怪兽（不取对象，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1只「剑斗兽」怪兽（非马斗）特殊召唤，并对其登记一个以原卡号为code的flag效果（用于后续限制/标记）。
function c25924653.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若没有可用主怪兽区，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足filter的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c25924653.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
