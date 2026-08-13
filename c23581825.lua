--RUM－ソウル・シェイブ・フォース
-- 效果：
-- ①：把基本分支付一半，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，比那只怪兽阶级高2阶的1只超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c23581825.initial_effect(c)
	-- ①：把基本分支付一半，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，比那只怪兽阶级高2阶的1只超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_DESTROY)
	e1:SetCost(c23581825.cost)
	e1:SetTarget(c23581825.target)
	e1:SetOperation(c23581825.activate)
	c:RegisterEffect(e1)
end
-- 效果发动代价处理：chk==0时判定支付条件成立，发动时实际支付一半基本分作为代价。
function c23581825.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 玩家tp支付当前LP一半（向下取整）的LP数值作为发动费用。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 墓地对象筛选：必须是「急袭猛禽」超量怪兽、能被特殊召唤，且额外卡组存在阶级比它高2阶的可作为素材的超量怪兽。
function c23581825.filter1(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在至少1张满足filter2的超量怪兽（阶级为对象怪兽阶级+2，且可作为对象怪兽的超量素材）。
		and Duel.IsExistingMatchingCard(c23581825.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+2)
end
-- 额外卡组超量怪兽筛选：其阶级必须等于对象怪兽阶级+2，可作为对象怪兽的超量素材，能以超量召唤方式特殊召唤，且对象怪兽离场后额外怪兽有可用区域；若额外怪兽为卡号6165656的怪兽，则对象必须为卡号48995978的No.88，否则不能选择。
function c23581825.filter2(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk) and mc:IsCanBeXyzMaterial(c)
		-- 确认额外怪兽可以以超量召唤方式特殊召唤，并且从额外卡组特召时有可用区域（考虑对象怪兽离场后腾出的位置）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的目标选择与合法性判定：选择墓地1只符合条件的「急袭猛禽」超量怪兽，并确认可进行2次特殊召唤、有怪兽区、无必须作为超量素材的限制。
function c23581825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23581825.filter1(chkc,e,tp) end
	-- 发动条件：本回合玩家还能进行至少2次特殊召唤（因为需要特殊召唤墓地怪兽和额外怪兽两只）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 发动条件：自己场上主要怪兽区至少有一个可用空格，用于特殊召唤墓地对象。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：不存在使某些卡必须作为超量素材的效果限制，确保两张怪兽能正常特殊召唤。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 发动条件：墓地存在1只满足filter1的「急袭猛禽」超量怪兽（已包含额外卡组有对应升阶怪兽的判定）。
		and Duel.IsExistingTarget(c23581825.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示框，提示玩家选择要特殊召唤的卡片（此提示用于后续的选卡操作界面）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1张满足filter1的「急袭猛禽」超量怪兽作为效果对象，并记录该对象与当前连锁的关联。
	local g=Duel.SelectTarget(tp,c23581825.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果预定进行2次特殊召唤，其中1只来自额外卡组，便于其他卡响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果处理：首先将墓地的对象怪兽特殊召唤；再选择额外卡组1只阶级高2阶的超量怪兽叠放在其上，作为超量召唤特殊召唤，并完成召唤手续。
function c23581825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用怪兽区，则无法特殊召唤任何怪兽，效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的对象怪兽（墓地那只急袭猛禽怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 将对象怪兽以表侧攻击表示特殊召唤到己方场上；若特殊召唤失败（返回0），则后续不处理。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查对象怪兽是否受到“必须作为超量素材”的效果限制，若有则中止升阶处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 弹出提示框，提示玩家选择要特殊召唤的额外卡组超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter2的超量怪兽（阶级为对象怪兽阶级+2，且可作为对象素材），确定为将要叠放升阶的怪兽。
	local g=Duel.SelectMatchingCard(tp,c23581825.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+2)
	local sc=g:GetFirst()
	if sc then
		-- 中断当前效果链，使之后的超量召唤作为独立事件处理，避免错过时点。
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽作为超量素材叠放在选择的额外超量怪兽下方（作为其超量素材）。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的额外超量怪兽以超量召唤方式特殊召唤到己方场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
