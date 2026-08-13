--粛声なる祝福
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「肃声之祝福」以外的自己的墓地·除外状态的1张「肃声」卡为对象才能发动。那张卡加入手卡。
-- ②：仪式怪兽以外的怪兽表侧表示召唤·特殊召唤的场合才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只战士族·龙族而光属性的仪式怪兽仪式召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
function c39114494.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以「肃声之祝福」以外的自己的墓地·除外状态的1张「肃声」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39114494,1))  --"回收「肃声」卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,39114494)
	e2:SetTarget(c39114494.thtg)
	e2:SetOperation(c39114494.thop)
	c:RegisterEffect(e2)
	-- ②：仪式怪兽以外的怪兽表侧表示召唤·特殊召唤的场合才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只战士族·龙族而光属性的仪式怪兽仪式召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39114494,2))  --"仪式召唤战士族·龙族光属性仪式怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,39114495)
	e3:SetCondition(c39114494.ricon)
	e3:SetTarget(c39114494.ritg)
	e3:SetOperation(c39114494.riop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 筛选可作为①效果对象的卡：不是「肃声之祝福」自身、处于表侧表示（含除外区表侧表示，排除里侧除外等状态）、属于「肃声」字段且能够加入手卡。
function c39114494.filter(c,e,tp)
	return not c:IsCode(39114494) and c:IsFaceupEx() and c:IsSetCard(0x1a6) and c:IsAbleToHand()
end
-- ①效果的发动条件与对象选择处理：先检查墓地/除外区是否存在符合filter的「肃声」卡，若存在则提示玩家选择1张作为对象，并根据对象所在位置（墓地或除外）设置对应的效果类别和操作信息。
function c39114494.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c39114494.filter(chkc,e,tp) end
	-- 在效果发动合法性检查中，确认自己墓地·除外区存在至少1张符合filter且能成为效果对象的「肃声」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c39114494.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送选择提示：请选择要加入手牌的卡（该消息将用于后续对象选择界面）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地/除外区选择1张满足filter的「肃声」卡作为效果对象，并将其登记为本连锁的对象卡。
	local tc=Duel.SelectTarget(tp,c39114494.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
		-- 设置操作信息：标记该效果涉及使对象卡离开墓地（CATEGORY_LEAVE_GRAVE），以配合相关效果（如王家长眠之谷）的发动检测。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND)
	end
end
-- ①效果的实际处理：取得效果对象，若对象仍与效果关联，则将该卡加入其持有者手卡。
function c39114494.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的效果对象卡（即作为回收对象的「肃声」卡）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc then
		-- 将对象卡以效果原因加入持有者手卡，完成回收。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的触发条件过滤器：被召唤的怪兽须为表侧表示且不是仪式怪兽（即“仪式怪兽以外的怪兽表侧表示召唤·特殊召唤”）。
function c39114494.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_RITUAL)
end
-- ②效果的发动条件：在本次召唤/特殊召唤成功的怪兽中，存在至少1只表侧表示且非仪式怪兽的怪兽。
function c39114494.ricon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39114494.cfilter,1,nil)
end
-- 仪式召唤对象的过滤条件：该怪兽须为仪式怪兽，且种族为战士族或龙族，属性为光属性。
function c39114494.rfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR)) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ②效果的发动时目标判定：检查手牌中是否有符合条件的仪式怪兽，并能用当前仪式素材凑出等级合计大于等于其等级的组合；同时设置特殊召唤的操作信息。
function c39114494.ritg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家可用的仪式召唤素材组（包含手卡、场上可解放的怪兽以及墓地中可作为仪式素材的特殊卡等）。
		local mg=Duel.GetRitualMaterial(tp)
		-- 检索手牌中是否存在满足rfilter条件且通过aux.RitualUltimateFilter判定的仪式怪兽，并能在现有素材中选出等级合计达到该怪兽等级以上的解放组合。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c39114494.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	end
	-- 设置操作信息：本效果将进行特殊召唤（仪式召唤），预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的实际处理：选择1只符合条件的仪式怪兽，从可用素材中选择能使其等级合计达到该怪兽等级以上的解放组，解放后以仪式召唤方式特殊召唤，并赋予其“不会被战斗破坏”的耐性。
function c39114494.riop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 再次获取当前玩家的仪式素材组，用于实际选择解放素材。
	local mg=Duel.GetRitualMaterial(tp)
	-- 向玩家发送选择提示：请选择要特殊召唤的卡（用于仪式怪兽选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足战士族·龙族·光属性仪式怪兽条件、且能用当前素材完成仪式召唤的怪兽作为要召唤的对象。
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c39114494.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 向玩家发送选择提示：请选择要解放的卡（用于仪式素材选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的仪式素材检查规则：按“大于等于”模式计算素材等级合计，在选素材时动态检查，避免选择无意义的多余素材。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家从可用素材中选择一组等级合计达到该仪式怪兽等级以上的素材（至少1张），并通过合法性检查；返回选中的素材组，若未选择则返回nil。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除临时的额外检查规则，防止影响后续其他效果处理。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local lv=mat:GetSum(Card.GetLevel)
		-- 解放选定的仪式素材（手卡/场上的怪兽送去墓地，墓地的仪式魔人等卡则除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前连锁处理，使之后的仪式召唤处理与解放素材处理分开（错开时点），以便正确触发相关时点。
		Duel.BreakEffect()
		-- 以仪式召唤方式将所选怪兽表侧表示特殊召唤到己方场上（跳过召唤条件检查但保留苏生限制），此步骤为特殊召唤流程的一部分。
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽不会被战斗破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(39114494,3))  --"「肃声之祝福」效果适用中，不会被战斗破坏"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:CompleteProcedure()
		end
		-- 完成这次特殊召唤流程，触发特殊召唤成功相关的时点与后续处理。
		Duel.SpecialSummonComplete()
	end
end
