--リサーガム・エクシーズ
-- 效果：
-- ①：自己场上的超量怪兽的攻击力上升800。
-- ②：1回合1次，从手卡丢弃1张魔法卡，以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。把「升阶魔法」魔法卡以外丢弃发动的场合，这个效果特殊召唤的怪兽在结束阶段回到持有者的额外卡组。
function c49082032.initial_effect(c)
	-- ①：自己场上的超量怪兽的攻击力上升800。（这段代码是魔法卡发动效果的设定，使此卡能够发动，发动成功后持续适用①效果）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	-- 限制该魔法卡只能在伤害步骤且伤害计算前发动，避免在伤害计算后等不适当时点发动。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：自己场上的超量怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 将攻击力上升效果的目标限定为自己场上的超量怪兽（仅超量怪兽适用）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从手卡丢弃1张魔法卡，以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。把「升阶魔法」魔法卡以外丢弃发动的场合，这个效果特殊召唤的怪兽在结束阶段回到持有者的额外卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49082032,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c49082032.spcost)
	e3:SetTarget(c49082032.sptg)
	e3:SetOperation(c49082032.spop)
	c:RegisterEffect(e3)
end
-- 定义可作为②效果发动代价的手牌魔法卡的条件：必须是魔法卡，且能够从手牌丢弃。
function c49082032.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 执行②效果的发动代价：从手牌选择并丢弃1张魔法卡；若丢弃的不是「升阶魔法」（字段0x95），则后续需要为特殊召唤的怪兽附加返回额外卡组的处理。
function c49082032.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：手牌中是否存在至少1张满足costfilter条件的魔法卡（即可丢弃的魔法卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c49082032.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，让玩家从手牌中选择要丢弃的卡（显示“请选择要丢弃的手牌”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1张满足costfilter条件的魔法卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c49082032.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetFirst():IsSetCard(0x95) then e:SetLabel(1) end
	-- 将选择的卡送去墓地，原因标记为代价和丢弃（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 定义②效果可选取对象怪兽的条件：自己场上表侧表示的超量怪兽，能够作为超量素材，且额外卡组中存在可与之进行超量召唤的符合条件的「混沌No.」或「混沌超量」怪兽。
function c49082032.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查对象怪兽没有受到“必须作为超量素材”等限制，确认它能够作为超量召唤的素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足spfilter2条件的怪兽：与对象相同种族、阶级高1阶、属于「混沌No.」或「混沌超量」字段且可特殊召唤。
		and Duel.IsExistingMatchingCard(c49082032.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRace(),c:GetRank()+1)
end
-- 定义可特殊召唤的额外怪兽的条件：与对象怪兽相同种族、阶级为对象阶级+1、卡名属于「混沌No.」或「混沌超量」字段、对象怪兽可与该怪兽进行超量召唤，并且该怪兽可以超量召唤方式特殊召唤及有额外怪兽区空格。
function c49082032.spfilter2(c,e,tp,mc,race,rk)
	return c:IsRace(race) and c:IsRank(rk) and c:IsSetCard(0x1048,0x1073) and mc:IsCanBeXyzMaterial(c)
		-- 确认额外怪兽能够以超量召唤方式特殊召唤（不检查召唤条件和不检查苏生限制），并确认有足够的额外怪兽区空格可供出场。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的发动目标选择：从自己场上选择1只满足spfilter1条件的超量怪兽作为对象，并设定后续将从额外卡组特殊召唤1只怪兽的操作信息。
function c49082032.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c49082032.spfilter1(chkc,e,tp) end
	-- 目标选择前检查：自己场上是否存在至少1只满足spfilter1条件的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49082032.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择效果对象（显示“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只满足条件的超量怪兽作为效果对象，同时将该怪兽登记为与当前连锁关联的对象。
	Duel.SelectTarget(tp,c49082032.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本次处理将进行从额外卡组的超量召唤（CATEGORY_SPECIAL_SUMMON，1只，从额外卡组特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：取得对象怪兽并确认其仍可作为素材且未离场等；选择符合条件的额外怪兽；将对象原有的超量素材和对象本身叠放在新怪兽下面；进行超量召唤；若丢弃的不是「升阶魔法」，则为该怪兽注册结束阶段返回持有者额外卡组的诱发效果；最后完成超量召唤手续。
function c49082032.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 再次检查对象怪兽是否仍满足作为超量素材的必备条件；若不满足则终止这次特殊召唤处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的额外卡组怪兽（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足spfilter2条件的「混沌No.」或「混沌超量」怪兽来进行超量召唤。
	local g=Duel.SelectMatchingCard(tp,c49082032.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRace(),tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原有的超量素材全部叠放到新特殊召唤的怪兽下面，使其继承原有素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽自身叠放到新怪兽下面，作为这次超量召唤的超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新怪兽以超量召唤的方式（SUMMON_TYPE_XYZ）表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		if e:GetLabel()~=1 then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			sc:RegisterFlagEffect(49082032,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 把「升阶魔法」魔法卡以外丢弃发动的场合，这个效果特殊召唤的怪兽在结束阶段回到持有者的额外卡组。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(sc)
			e1:SetCondition(c49082032.retcon)
			e1:SetOperation(c49082032.retop)
			-- 将结束阶段返回额外卡组的诱发效果注册到当前玩家场上，使该效果在结束阶段时点能够执行。
			Duel.RegisterEffect(e1,tp)
		end
		sc:CompleteProcedure()
	end
end
-- 返回效果的发动条件：确认该怪兽仍带有对应标记（未离场或未被重置）；若标记已丢失，则重置该效果并不执行返回。
function c49082032.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(49082032)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 返回效果的处理：将标记对应的那只怪兽返回持有者的额外卡组。
function c49082032.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽洗回持有者的卡组（此处因是额外卡组怪兽，实际回到持有者的额外卡组），原因标记为效果处理。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
