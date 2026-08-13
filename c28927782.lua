--ドラグニティ・ドライブ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。这个回合，自己不是「龙骑兵团」怪兽不能特殊召唤。
-- ●以自己的魔法与陷阱区域1张「龙骑兵团」怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
-- ●以自己场上1只「龙骑兵团」怪兽为对象才能发动。从自己墓地选1只「龙骑兵团」怪兽当作装备卡使用给作为对象的自己怪兽装备。
function c28927782.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以从以下效果选择1个发动。这个回合，自己不是「龙骑兵团」怪兽不能特殊召唤。●以自己的魔法与陷阱区域1张「龙骑兵团」怪兽卡为对象才能发动。那张卡守备表示特殊召唤。●以自己场上1只「龙骑兵团」怪兽为对象才能发动。从自己墓地选1只「龙骑兵团」怪兽当作装备卡使用给作为对象的自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,28927782)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c28927782.eftg)
	e2:SetOperation(c28927782.efop)
	c:RegisterEffect(e2)
end
-- 特殊召唤分支的候选过滤：判断卡是否为表侧表示、属于「龙骑兵团」且能够被这个效果特殊召唤（不检查召唤条件与苏生限制）。
function c28927782.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 装备分支的对象过滤：选择自己场上表侧表示且属于「龙骑兵团」的怪兽，且自己墓地存在至少1张可装备的「龙骑兵团」怪兽。
function c28927782.eqfilter1(c,tp)
	-- 装备分支对象进一步成立的条件：目标为表侧表示且属「龙骑兵团」，并且以该怪兽为装备对象时，可从自己墓地找到至少1张满足eqfilter2的「龙骑兵团」怪兽。
	return c:IsFaceup() and c:IsSetCard(0x29) and Duel.IsExistingMatchingCard(c28927782.eqfilter2,tp,LOCATION_GRAVE,0,1,nil,c,tp)
end
-- 墓地装备卡候选过滤：是「龙骑兵团」怪兽卡，且不是禁止作为装备的卡（可供本次效果当作装备卡装备）。
function c28927782.eqfilter2(c,tc,tp)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 对象合法性检查：根据e:GetLabel()选择的分支检查指定对象是否合法——分支0要求来自自己魔法与陷阱区且满足spfilter，分支1要求来自自己场上且满足eqfilter1。
function c28927782.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c28927782.spfilter(chkc,e,tp)
		else return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28927782.eqfilter1(chkc,tp) end
	end
	-- 判断能否选择特殊召唤分支：自己主要怪兽区有空位，且自己魔法与陷阱区存在至少1张表侧表示的「龙骑兵团」怪兽可作为特殊召唤对象。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c28927782.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
	-- 判断能否选择装备分支：自己魔法与陷阱区有空位，且自己场上存在至少1只「龙骑兵团」怪兽可作为装备对象（并存在可装备的墓地卡）。
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(c28927782.eqfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支都可用时，让玩家选择发动特殊召唤还是装备效果，返回值作为分支标记存入op。
		op=Duel.SelectOption(tp,aux.Stringid(28927782,1),aux.Stringid(28927782,2))  --"特殊召唤/装备"
	elseif b1 then
		-- 只有特殊召唤分支可用时，用单项选择确认该分支，op为0。
		op=Duel.SelectOption(tp,aux.Stringid(28927782,1))  --"特殊召唤"
	-- 只有装备分支可用时，用单项选择确认该分支；因为单项选择返回0，加1使op与双分支中的装备分支编号一致。
	else op=Duel.SelectOption(tp,aux.Stringid(28927782,2))+1 end  --"装备"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己魔法与陷阱区选择1张满足spfilter的「龙骑兵团」怪兽卡作为特殊召唤对象，同时登记为本次连锁的取对象目标。
		local g=Duel.SelectTarget(tp,c28927782.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		-- 向连锁操作信息登记本次处理将进行特殊召唤，对象为已选卡片g，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		-- 向玩家显示“请选择表侧表示的卡”的提示消息，用于选择装备分支的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从自己场上选择1只满足eqfilter1的「龙骑兵团」怪兽作为装备对象，同时登记为本次连锁的取对象目标。
		Duel.SelectTarget(tp,c28927782.eqfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
		-- 向连锁操作信息登记本次处理涉及从墓地离开（选取装备卡），目标数量为1，具体卡在处理时确定，因此targets为nil。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	end
end
-- 效果处理：根据分支标记执行——分支0将对象「龙骑兵团」怪兽卡表侧守备特殊召唤；分支1从自己墓地选「龙骑兵团」怪兽装备给对象怪兽；随后给发动者附加本回合只能特殊召唤「龙骑兵团」怪兽的誓约限制。
function c28927782.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 获取特殊召唤分支选定的连锁对象（魔陷区的龙骑兵团怪兽卡）。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将对象龙骑兵团怪兽卡以表侧守备表示特殊召唤到自己的主要怪兽区（不检查召唤条件，不检查苏生限制）。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	else
		-- 装备分支前检查自己的魔法与陷阱区是否有空位，若无空位则无法装备并结束处理。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 获取装备分支选定的连锁对象（自己场上的龙骑兵团怪兽）。
		local ec=Duel.GetFirstTarget()
		if ec:IsRelateToEffect(e) and ec:IsFaceup() then
			-- 向玩家显示“请选择要装备的卡”的提示消息，用于从墓地选择装备卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从自己墓地选择1张「龙骑兵团」怪兽作为装备卡，过滤条件为eqfilter2，并排除受王家长眠之谷影响而不能从墓地使用的卡。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28927782.eqfilter2),tp,LOCATION_GRAVE,0,1,1,nil,ec,tp)
			local tc=g:GetFirst()
			-- 若没有选出可装备的卡，或装备操作失败，则直接终止本次效果的后续处理。
			if not tc or not Duel.Equip(tp,tc,ec) then return end
			-- 当作装备卡使用给作为对象的自己怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c28927782.eqlimit2)
			e1:SetLabelObject(ec)
			tc:RegisterEffect(e1)
		end
	end
	-- 这个回合，自己不是「龙骑兵团」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c28927782.splimit)
	-- 将上述“不能特殊召唤非龙骑兵团怪兽”的誓约限制效果注册到决斗中，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：若将要特殊召唤的怪兽不是「龙骑兵团」怪兽，则禁止该特殊召唤。
function c28927782.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x29)
end
-- 装备限制判定函数：只有将装备卡装备给记录的指定对象（e:GetLabelObject()）时才允许装备。
function c28927782.eqlimit2(e,c)
	return c==e:GetLabelObject()
end
