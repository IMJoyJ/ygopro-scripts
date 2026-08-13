--聖騎士と聖剣の巨城
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡直到下次的准备阶段除外，从自己的手卡·卡组·墓地把1张「圆桌的圣骑士」在自己的场地区域表侧表示放置。那之后，以下效果可以适用。
-- ●从自己的卡组·墓地把1只「阿托利斯」怪兽特殊召唤或把1张「圣剑」卡加入手卡。
-- ②：1回合1次，自己场上的「圣骑士」卡被战斗·效果破坏的场合，可以作为代替把自己场上1张装备卡破坏。
local s,id,o=GetID()
-- 初始化卡片的三个效果：登记卡名提及的「圆桌的圣骑士」，注册场地魔法卡的发动空效果、②代替破坏效果和①起动效果。
function s.initial_effect(c)
	-- 将卡号55742055（圆桌的圣骑士）登记为此卡记述的卡名，供相关检索与判定使用。
	aux.AddCodeList(c,55742055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的「圣骑士」卡被战斗·效果破坏的场合，可以作为代替把自己场上1张装备卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。这张卡直到下次的准备阶段除外，从自己的手卡·卡组·墓地把1张「圆桌的圣骑士」在自己的场地区域表侧表示放置。那之后，以下效果可以适用。●从自己的卡组·墓地把1只「阿托利斯」怪兽特殊召唤或把1张「圣剑」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.rptg)
	e3:SetOperation(s.rpop)
	c:RegisterEffect(e3)
end
-- 判定怪兽是否为因战斗/效果被破坏的我方场上表侧表示「圣骑士」怪兽，且未被作为代替破坏处理过。
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤可作为代替破坏对象的装备卡，要求其装备在我方怪兽上、可被效果破坏且尚未被选为代替破坏对象。
function s.dfilter(c,e)
	return c:GetEquipTarget() and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- ②效果的发动条件：我方场上有因战斗/效果被破坏的「圣骑士」怪兽，且存在可代替破坏的装备卡。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方场上所有可作为代替破坏对象的装备卡集合。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_SZONE,0,nil,e)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp)
		and #g>0 end
	local c=e:GetHandler()
	-- 询问玩家是否发动②的代替破坏效果，以决定是否进行代替破坏。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示选择提示，让玩家选择一张要代替破坏的装备卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选定的装备卡设置为当前效果的处理对象，便于后续处理时取回。
		Duel.SetTargetCard(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏处理：清除装备卡的破坏确认标记，然后将该装备卡破坏以代替怪兽被破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此前被设置为代替破坏对象的装备卡。
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果和代替破坏为理由破坏该装备卡，完成代替破坏动作。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 作为代替破坏效果的判定函数，返回被破坏的怪兽是否是我方场上被战斗/效果破坏的「圣骑士」怪兽。
function s.repval(e,c)
	return s.filter(c,e:GetHandlerPlayer())
end
-- 过滤可放置到场地区域的「圆桌的圣骑士」：卡号一致、未被禁止，且不违反同名卡上场限制。
function s.pfilter(c,tp)
	return c:IsCode(55742055) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件：本卡可以除外，且我方手卡·卡组·墓地存在符合条件的「圆桌的圣骑士」。
function s.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查我方手卡·卡组·墓地是否存在1张符合条件的「圆桌的圣骑士」。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
	-- 设置本效果的操作信息为除外这张卡，供其他相关效果判断。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 过滤①后续效果可选的卡片：若为「阿托利斯」怪兽则需能特殊召唤，若为「圣剑」卡则需能加入手卡。
function s.sfilter(c,e,tp)
	-- 若是「阿托利斯」怪兽，检查我方怪兽区是否有空位且该怪兽能够特殊召唤。
	if c:IsSetCard(0xa7) then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	elseif c:IsSetCard(0x207a) then return c:IsAbleToHand() end
	return false
end
-- 执行①效果：暂时除外本卡并设定准备阶段回归；选1张「圆桌的圣骑士」放到我方场地区域；之后可选从卡组·墓地选「阿托利斯」怪兽特殊召唤或「圣剑」卡加入手卡。
function s.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将本卡表侧表示暂时除外；若除外失败或未进入除外区则直接结束处理。
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 or not c:IsLocation(LOCATION_REMOVED) then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	-- ①：自己主要阶段才能发动。这张卡直到下次的准备阶段除外，从自己的手卡·卡组·墓地把1张「圆桌的圣骑士」在自己的场地区域表侧表示放置。那之后，以下效果可以适用。●从自己的卡组·墓地把1只「阿托利斯」怪兽特殊召唤或把1张「圣剑」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 将准备阶段回归的持续效果注册到决斗中，用于在下次准备阶段把本卡移回场地区域。
	Duel.RegisterEffect(e1,tp)
	-- 显示“请选择要放置到场上的卡”的提示，准备选择「圆桌的圣骑士」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡·卡组·墓地选择1张符合条件的「圆桌的圣骑士」，若墓地受王家长眠之谷影响则会自动排除。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	-- 将选中的「圆桌的圣骑士」正面表示放置到自己的场地区域，若未成功则结束处理。
	if not (tc and Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)) then return end
	-- 从卡组·墓地获取可进行后续处理的「阿托利斯」怪兽或「圣剑」卡的集合。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 若存在可选卡且玩家选择适用后续效果，则继续处理；否则结束。
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选卡特殊召唤或加入手卡？"
		-- 显示“请选择要操作的卡”的提示，让玩家选择要特殊召唤或加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sc=tg:Select(tp,1,1,nil):GetFirst()
		-- 判断所选卡是否能作为「阿托利斯」怪兽特殊召唤（需怪兽区有空位且满足召唤条件）。
		local b1=sc:IsSetCard(0xa7) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=sc:IsSetCard(0x207a) and sc:IsAbleToHand()
		-- 让玩家选择将所选卡特殊召唤还是加入手卡；不可用的选项不会显示。
		local op=aux.SelectFromOptions(tp,{b1,1152},{b2,1190})
		-- 中断当前效果处理，使接下来的特殊召唤/加入手卡作为独立处理，避免错过时点。
		Duel.BreakEffect()
		if op==2 then
			-- 将选中的「圣剑」卡加入其持有者的手卡。
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 向对方玩家展示这张加入手卡的卡。
			Duel.ConfirmCards(1-tp,sc)
		-- 否则将选中的「阿托利斯」怪兽表侧表示特殊召唤到我方场上。
		else Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end
	end
end
-- 准备阶段回归效果的发动条件：本卡仍带有暂时除外的标记。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetOwner():GetFlagEffect(id)>0
end
-- 准备阶段回归处理：若场地区域已有卡则将其送墓，再把暂时除外的本卡移回场地区域。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方场地区域第0格的卡片（当前场地魔法卡）。
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		-- 以规则理由将原场地区域的卡片送去墓地，以腾出场地。
		Duel.SendtoGrave(fc,REASON_RULE)
		-- 中断当前效果处理，使本卡返回场地的动作作为独立处理。
		Duel.BreakEffect()
	end
	-- 将暂时除外的本卡正面表示移回我方场地区域，并立即适用其效果。
	Duel.MoveToField(e:GetOwner(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	e:Reset()
end
