--暗黒の魔再生
-- 效果：
-- ①：对方怪兽的攻击宣言时，以对方墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ②：把墓地的这张卡除外，从手卡以及自己场上盖放的卡之中把1张「死者苏生」送去墓地才能发动。从自己墓地选1只「太阳神之翼神龙」无视召唤条件特殊召唤。那之后，可以选对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽在结束阶段送去墓地。
function c12930501.initial_effect(c)
	-- 登记这张卡效果文本中提到的「太阳神之翼神龙」的卡号，使涉及该卡名的检索、判定等逻辑可用。
	aux.AddCodeList(c,10000010)
	-- ①：对方怪兽的攻击宣言时，以对方墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12930501,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c12930501.condition)
	e1:SetTarget(c12930501.target)
	e1:SetOperation(c12930501.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从手卡以及自己场上盖放的卡之中把1张「死者苏生」送去墓地才能发动。从自己墓地选1只「太阳神之翼神龙」无视召唤条件特殊召唤。那之后，可以选对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽在结束阶段送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12930501,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(c12930501.spcost)
	e2:SetTarget(c12930501.sptg)
	e2:SetOperation(c12930501.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定：确认发动者是回合玩家的对手，即当前是对方回合且对方怪兽进行了攻击宣言。
function c12930501.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前操作玩家不是回合玩家，满足“对方怪兽的攻击宣言时”中“对方”的条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 定义效果①的对象筛选函数：被选卡必须是可以盖放的魔法卡，且若它不是场地魔法，则己方魔陷区必须还有空位。
function c12930501.filter(c,ft)
	return c:IsType(TYPE_SPELL) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or ft>0)
end
-- 效果①的发动目标处理：计算己方可用的魔陷区数量，从对方墓地选择1张符合条件的魔法卡作为对象，并登记操作信息。
function c12930501.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方魔法陷阱区当前剩余可用空格数，用于判断能否将目标魔法卡盖放到自己场上。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c12930501.filter(chkc,ft) end
	-- 效果发动合法性检查：确认对方墓地至少存在1张满足条件且可作为对象的魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c12930501.filter,tp,0,LOCATION_GRAVE,1,nil,ft) end
	-- 弹出选择提示，告知玩家接下来要选择的是要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从对方墓地选择1张符合条件的魔法卡，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c12930501.filter,tp,0,LOCATION_GRAVE,1,1,nil,ft)
	-- 设置连锁操作信息，声明该效果涉及从墓地移出卡片，供「王家长眠之谷」等效果进行联动检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
-- 效果①成功发动后的处理：取得对象卡，若对象卡仍与效果关联，则将其盖放到己方魔陷区。
function c12930501.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那张对象魔法卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象魔法卡以里侧表示盖放到当前玩家（这张卡的控制者）的魔法与陷阱区。
		Duel.SSet(tp,tc,tp)
	end
end
-- 定义作为②的cost的「死者苏生」筛选条件：卡号为83764718，可以送去墓地作为cost，并且必须位于手牌或己方场上里侧表示。
function c12930501.spcfilter(c)
	return c:IsCode(83764718) and c:IsAbleToGraveAsCost()
		and (c:IsFacedown() or c:IsLocation(LOCATION_HAND))
end
-- 定义②的cost检查函数：在chk==0时确认能够支付cost，即墓地中的本卡可以除外，且存在符合条件的「死者苏生」可供送墓。
function c12930501.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 追加cost检查：确认手牌或己方场上里侧表示中至少存在1张可送去墓地的「死者苏生」。
		and Duel.IsExistingMatchingCard(c12930501.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	-- 实际支付cost：将墓地中的这张卡（暗黑之魔再生）表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 弹出选择提示，告知玩家要选择送去墓地的「死者苏生」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌以及己方场上里侧表示的卡中，选择1张符合条件的「死者苏生」用于支付cost。
	local g=Duel.SelectMatchingCard(tp,c12930501.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	-- 将选中的「死者苏生」送去墓地，完成cost支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义特殊召唤对象的筛选条件：必须是「太阳神之翼神龙」，且能够被该效果无视召唤条件特殊召唤。
function c12930501.sptgfilter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②的发动目标处理：确认自己墓地存在可特殊召唤的「太阳神之翼神龙」且自己怪兽区有空位，并设置操作信息。
function c12930501.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己墓地至少存在1只符合条件的「太阳神之翼神龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c12930501.sptgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时确认自己场上有足够怪兽区域可以特殊召唤，否则不能发动。
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置连锁操作信息，声明该效果将进行从墓地的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 定义“把对方场上1只怪兽送去墓地”的筛选条件：对方场上的怪兽可以被送去墓地。
function c12930501.tgfilter(c)
	return c:IsAbleToGrave()
end
-- 效果②处理时：在自己的怪兽区空位足够的情况下，从自己墓地选择1只「太阳神之翼神龙」无视召唤条件特殊召唤；成功后登记结束阶段送墓效果，并可选将对方场上1只怪兽送去墓地。
function c12930501.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己怪兽区是否有空位，若没有则整个特殊召唤处理直接失败。
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 弹出选择提示，告知玩家要选择特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地中选择1只符合条件的「太阳神之翼神龙」，并取得这张卡。
	local tc=Duel.SelectMatchingCard(tp,c12930501.sptgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 若选到了目标卡，则将其无视召唤条件、以表侧表示特殊召唤到自己场上；特殊召唤成功才继续后续处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(12930501,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 那之后，可以选对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽在结束阶段送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c12930501.tgcon)
		e1:SetOperation(c12930501.tgop)
		-- 将结束阶段把特殊召唤的「太阳神之翼神龙」送去墓地的持续效果注册到整个场上，由当前玩家控制。
		Duel.RegisterEffect(e1,tp)
		-- 检查对方场上是否存在至少1只可以被送去墓地的怪兽，以决定是否提供“把对方怪兽送去墓地”的追加处理。
		if Duel.IsExistingMatchingCard(c12930501.tgfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问当前玩家是否选择对方场上1只怪兽送去墓地，对应“那之后，可以选对方场上1只怪兽送去墓地”。
			and Duel.SelectYesNo(tp,aux.Stringid(12930501,2)) then  --"是否选对方怪兽送去墓地？"
			-- 中断当前效果处理，使后续“送对方怪兽去墓地”的处理不视为同一效果中的连续处理，避免错过时点。
			Duel.BreakEffect()
			-- 弹出选择提示，告知玩家要选择送去墓地的对方怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从对方场上选择1只满足条件的怪兽，作为追加送墓处理的对象。
			local g=Duel.SelectMatchingCard(tp,c12930501.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 高亮展示被选中的怪兽，并将其记录为效果对象。
			Duel.HintSelection(g)
			-- 将选中的对方怪兽以效果原因送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 结束阶段送墓效果的触发条件判定：检查特殊召唤的怪兽是否仍然带有本次特殊召唤的标记，若标记不一致则取消该效果。
function c12930501.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(12930501)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段送墓效果的解决：将之前特殊召唤的「太阳神之翼神龙」送去墓地。
function c12930501.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行：将记录在效果标签中的「太阳神之翼神龙」在结束阶段送去墓地。
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
