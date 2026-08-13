--優麗なる霊鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只4星以下的怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。那之后，作为对象的怪兽当作装备卡使用给那只特殊召唤的怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力上升这个效果装备的怪兽的攻击力一半数值。这个回合，自己不能把那张装备卡以及那些同名卡的效果发动。
function c18954366.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只4星以下的怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。那之后，作为对象的怪兽当作装备卡使用给那只特殊召唤的怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力上升这个效果装备的怪兽的攻击力一半数值。这个回合，自己不能把那张装备卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18954366+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c18954366.target)
	e1:SetOperation(c18954366.activate)
	c:RegisterEffect(e1)
end
-- 特殊召唤候选怪兽的过滤：必须是怪兽卡、等级不高于对象怪兽的等级、且能够被当前效果特殊召唤。
function c18954366.spfilter(c,e,tp,lv)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地对象怪兽的过滤：必须是怪兽卡、等级4以下、手牌存在可特殊召唤的低星怪兽、不是禁止卡且自己场上没有同名卡。
function c18954366.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
		-- 确认手牌中存在至少1只等级不高于对象怪兽等级且能够被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c18954366.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetLevel())
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 连锁处理时若需校验对象，要求对象存在于自己墓地、为自己控制的4星以下怪兽。
function c18954366.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsType(TYPE_MONSTER) and chkc:IsLevelBelow(4) end
	local ft=1
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=2 end
	-- 发动条件之一：自己主要怪兽区必须有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之一：若从手卡发动魔法卡则需额外占用1个魔陷区，因此魔陷区空位至少为ft（一般为2，后场发动时为1）。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>=ft
		-- 确认自己墓地存在满足所有条件的对象怪兽。
		and Duel.IsExistingTarget(c18954366.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地选择1只满足条件的怪兽作为效果对象并建立联系。
	local g=Duel.SelectTarget(tp,c18954366.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息：本次效果处理中包含从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置墓地卡移动的操作信息：本次效果处理中对象怪兽将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：确认对象仍与效果相关且怪兽区有空位；选择1只等级不高于对象等级的手卡怪兽特殊召唤；成功后将对象作为装备卡装备，并赋予攻击力上升效果及同名卡效果发动自肃；若装备成功还设置仅能装备给该特殊召唤怪兽的限制。
function c18954366.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 若自己主要怪兽区没有空位，则无法进行特殊召唤，效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=tc:GetLevel()
	local atk=tc:GetAttack()
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只等级不高于对象怪兽等级且可特殊召唤的怪兽。
	local sc=Duel.SelectMatchingCard(tp,c18954366.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv):GetFirst()
	-- 若成功选择了怪兽且将其表侧表示特殊召唤成功，则继续后续处理。
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0
		and not tc:IsForbidden() and tc:CheckUniqueOnField(tp)
		-- 将对象怪兽作为装备卡装备给刚特殊召唤的怪兽。
		and Duel.Equip(tp,tc,sc) then
		if atk>0 then
			-- 只要这个效果把怪兽装备中，装备怪兽的攻击力上升这个效果装备的怪兽的攻击力一半数值。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 这个回合，自己不能把那张装备卡以及那些同名卡的效果发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(1,0)
		e2:SetValue(c18954366.aclimit)
		e2:SetLabel(tc:GetCode())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将“不能发动同名卡效果”的自肃效果注册到场上，当前玩家生效。
		Duel.RegisterEffect(e2,tp)
		-- 那之后，作为对象的怪兽当作装备卡使用给那只特殊召唤的怪兽装备。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetLabelObject(sc)
		e3:SetValue(c18954366.eqlimit)
		tc:RegisterEffect(e3)
	end
end
-- 自肃判定：若要发动的效果来自卡名与记录卡名相同的卡，则禁止该效果的发动。
function c18954366.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 装备限制判定：只允许该装备卡装备给之前特殊召唤的特定怪兽。
function c18954366.eqlimit(e,c)
	return c==e:GetLabelObject()
end
