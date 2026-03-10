--クロック・リザード
-- 效果：
-- 电子界族怪兽2只
-- ①：把这张卡解放才能发动。从自己墓地选1只融合怪兽回到额外卡组。那之后，那张融合怪兽卡决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
-- ②：墓地的这张卡被除外的场合才能发动。对方场上的特殊召唤的怪兽的攻击力直到回合结束时下降自己墓地的电子界族怪兽数量×400。
function c51476410.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只电子界族怪兽作为连接素材
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
-- 效果处理时检查是否可以解放自身，若可以则进行解放操作
function c51476410.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为效果发动的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足条件的卡片：是怪兽、能成为融合素材、能除外
function c51476410.spfilter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤满足条件的卡片：是怪兽、能成为融合素材、能除外、不受当前效果影响
function c51476410.spfilter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 检查卡片是否可以特殊召唤为融合怪兽，以及是否满足融合素材要求
function c51476410.spfilter2(c,e,tp,m,f,chkf)
	return (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查卡片是否为融合怪兽且能返回额外卡组，并判断是否有足够的额外卡组召唤空间
function c51476410.spfilter3(c,e,tp,chkf,rc)
	if not c:IsType(TYPE_FUSION) or not c:IsAbleToExtra() then return false end
	-- 判断玩家在额外卡组是否有足够的召唤空间
	if Duel.GetLocationCountFromEx(tp,tp,rc,TYPE_FUSION)<=0 then return false end
	-- 获取墓地中的所有满足条件的卡片作为融合素材候选
	local mg=Duel.GetMatchingGroup(c51476410.spfilter0,tp,LOCATION_GRAVE,0,c)
	local res=c51476410.spfilter2(c,e,tp,mg,nil,chkf)
	if not res then
		-- 获取当前连锁中使用的融合素材效果
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
-- 设置效果发动的检查条件：玩家可以除外卡片，并且墓地中存在满足条件的融合怪兽
function c51476410.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=PLAYER_NONE
	-- 检查玩家是否可以除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 检查墓地是否存在满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c51476410.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp,chkf,e:GetHandler()) end
	-- 设置操作信息：将一张卡从墓地送入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：将一张卡从额外卡组特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：选择并送回额外卡组，然后进行融合召唤
function c51476410.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以除外卡片，若不可以则不执行效果
	if not Duel.IsPlayerCanRemove(tp) then return end
	local chkf=tp
	-- 提示玩家选择要返回额外卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地中选择一张满足条件的融合怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51476410.spfilter3),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,chkf,nil)
	local tc=g:GetFirst()
	-- 将选中的卡片送回额外卡组，并确认其已进入额外卡组
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 获取墓地中所有满足条件的卡片作为融合素材候选
		local mg1=Duel.GetMatchingGroup(c51476410.spfilter1,tp,LOCATION_GRAVE,0,nil,e)
		local mgchk1=c51476410.spfilter2(tc,e,tp,mg1,nil,chkf)
		local mg2=nil
		local mgchk2=false
		-- 获取当前连锁中使用的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			mgchk2=c51476410.spfilter2(tc,e,tp,mg2,mf,chkf)
		end
		if mgchk1 or mgchk2 then
			-- 判断是否选择使用第一种融合方式，若选择则使用第一种方式
			if mgchk1 and (not mgchk2 or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 从满足条件的卡片中选择融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选中的融合素材从场上除外
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 将融合怪兽特殊召唤到场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 从满足条件的卡片中选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 判断效果发动条件：卡片在墓地中被除外且处于正面表示状态
function c51476410.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤满足条件的卡片：是正面表示、是特殊召唤的怪兽
function c51476410.atkfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置效果发动的检查条件：墓地存在电子界族怪兽，对方场上存在特殊召唤的怪兽
function c51476410.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_CYBERSE)
		-- 检查对方场上是否存在特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c51476410.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：对符合条件的怪兽攻击力进行调整
function c51476410.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有特殊召唤怪兽
	local g=Duel.GetMatchingGroup(c51476410.atkfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 计算攻击力下降值，为墓地电子界族怪兽数量乘以400
	local atk=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_CYBERSE)*400
	local tc=g:GetFirst()
	while tc do
		-- 为选中的怪兽添加攻击力下降效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
