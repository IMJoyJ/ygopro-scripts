--クロック・リザード
-- 效果：
-- 电子界族怪兽2只
-- ①：把这张卡解放才能发动。从自己墓地选1只融合怪兽回到额外卡组。那之后，那张融合怪兽卡决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
-- ②：墓地的这张卡被除外的场合才能发动。对方场上的特殊召唤的怪兽的攻击力直到回合结束时下降自己墓地的电子界族怪兽数量×400。
function c51476410.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设置连接召唤手续：需要2只电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- ①：把这张卡解放才能发动。从自己墓地选1只融合怪兽回到额外卡组。那之后，那张融合怪兽卡决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51476410,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c51476410.spcost)
	e1:SetTarget(c51476410.sptg)
	e1:SetOperation(c51476410.spop)
	c:RegisterEffect(e1)
	-- ②：墓地的这张卡被除外的场合才能发动。对方场上的特殊召唤的怪兽的攻击力直到回合结束时下降自己墓地的电子界族怪兽数量×400。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51476410,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(c51476410.atkcon)
	e2:SetTarget(c51476410.atktg)
	e2:SetOperation(c51476410.atkop)
	c:RegisterEffect(e2)
end
-- 发动代价判定/支付：检查这张卡是否可解放，若可解放则将其解放作为效果发动的代价。
function c51476410.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤墓地中可作为融合素材且能被除外的怪兽卡，作为融合素材候选。
function c51476410.spfilter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤墓地中可作为融合素材、能被除外且不受该效果影响的怪兽卡，用于选择融合素材。
function c51476410.spfilter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 检查融合怪兽能否用给定素材进行融合召唤，即满足特殊召唤条件且素材组合合法。
function c51476410.spfilter2(c,e,tp,m,f,chkf)
	return (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 选择墓地融合怪兽的过滤：必须是融合怪兽、能回额外卡组、有额外区空格，且存在合法融合素材（通常素材或连锁素材）。
function c51476410.spfilter3(c,e,tp,chkf,rc)
	if not c:IsType(TYPE_FUSION) or not c:IsAbleToExtra() then return false end
	-- 检查从额外卡组特殊召唤所需的可用区域，若没有空格则不能选择该融合怪兽。
	if Duel.GetLocationCountFromEx(tp,tp,rc,TYPE_FUSION)<=0 then return false end
	-- 获取自己墓地中满足spfilter0条件的怪兽卡，作为常规融合素材候选组。
	local mg=Duel.GetMatchingGroup(c51476410.spfilter0,tp,LOCATION_GRAVE,0,c)
	local res=c51476410.spfilter2(c,e,tp,mg,nil,chkf)
	if not res then
		-- 获取“连锁素材”效果，作为替代融合素材来源。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=c51476410.spfilter2(c,e,tp,mg,mf,chkf)
		end
	end
	return res
end
-- ①效果的发动条件检查：玩家可以除外卡片，且墓地存在1只满足spfilter3的融合怪兽。
function c51476410.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=PLAYER_NONE
	-- 效果发动合法检查：确认玩家当前可以进行除外操作。
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 效果发动合法检查：确认墓地存在至少1张可返回额外卡组并可融合召唤的融合怪兽。
		and Duel.IsExistingMatchingCard(c51476410.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp,chkf,e:GetHandler()) end
	-- 设置操作信息：效果处理时从墓地返回1张卡到额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：效果处理时从额外卡组特殊召唤1只怪兽（融合召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的实际处理：选择墓地1只融合怪兽返回额外卡组，从墓地除外融合素材并进行融合召唤。
function c51476410.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理中，若玩家不能除外卡片，则整个效果不处理。
	if not Duel.IsPlayerCanRemove(tp) then return end
	local chkf=tp
	-- 显示选择提示，要求玩家选择要返回卡组（额外卡组）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张满足条件且不受王家长眠之谷影响的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51476410.spfilter3),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,chkf,nil)
	local tc=g:GetFirst()
	-- 将选中的融合怪兽返回额外卡组；若返回成功且该卡确实在额外卡组，则继续融合召唤处理。
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 获取自己墓地中可作为融合素材且不受该效果影响的卡组，用于通常融合召唤。
		local mg1=Duel.GetMatchingGroup(c51476410.spfilter1,tp,LOCATION_GRAVE,0,nil,e)
		local mgchk1=c51476410.spfilter2(tc,e,tp,mg1,nil,chkf)
		local mg2=nil
		local mgchk2=false
		-- 获取“连锁素材”效果，用于替代融合素材来源。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			mgchk2=c51476410.spfilter2(tc,e,tp,mg2,mf,chkf)
		end
		if mgchk1 or mgchk2 then
			-- 决定使用通常素材还是连锁素材：若通常素材可用且玩家不选择连锁素材，则走通常素材流程。
			if mgchk1 and (not mgchk2 or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从通常素材组中选择融合怪兽所需的融合素材。
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选择的融合素材从墓地除外，作为融合素材。
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果，使后续融合召唤作为独立处理，避免时点被占用。
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到自己的场上。
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 让玩家从连锁素材提供的素材组中选择融合素材。
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- ②效果的发动条件：这张卡在墓地期间被除外，且除外后表侧表示。
function c51476410.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤对方场上表侧表示且通过特殊召唤出场的怪兽。
function c51476410.atkfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ②效果的发动条件检查：自己墓地有电子界族怪兽，且对方场上有特殊召唤的表侧怪兽。
function c51476410.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_CYBERSE)
		-- 检查对方场上是否存在至少1只表侧表示的特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(c51476410.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果处理：对方场上所有特殊召唤的表侧怪兽攻击力下降自己墓地电子界族数量×400，直到回合结束。
function c51476410.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示且特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(c51476410.atkfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 计算自己墓地电子界族怪兽数量并乘以400，得到攻击力下降数值。
	local atk=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_CYBERSE)*400
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的特殊召唤的怪兽的攻击力直到回合结束时下降自己墓地的电子界族怪兽数量×400。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
