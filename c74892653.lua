--スターダスト・ウォリアー
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- ①：对方把怪兽特殊召唤之际，把这张卡解放才能发动。那个无效，那些怪兽破坏。
-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
-- ③：战斗或者对方的效果让表侧表示的这张卡从场上离开的场合才能发动。从额外卡组把1只8星以下的「战士」同调怪兽当作同调召唤作特殊召唤。
function c74892653.initial_effect(c)
	-- 设置同调召唤手续：同调怪兽调整+调整以外的同调怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：对方把怪兽特殊召唤之际，把这张卡解放才能发动。那个无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74892653,0))  --"无效特殊召唤"
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c74892653.condition)
	e1:SetCost(c74892653.cost)
	e1:SetTarget(c74892653.target)
	e1:SetOperation(c74892653.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74892653,1))  --"苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c74892653.sptg)
	e2:SetOperation(c74892653.spop)
	c:RegisterEffect(e2)
	-- ③：战斗或者对方的效果让表侧表示的这张卡从场上离开的场合才能发动。从额外卡组把1只8星以下的「战士」同调怪兽当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74892653,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCondition(c74892653.sccon)
	e3:SetTarget(c74892653.sctg)
	e3:SetOperation(c74892653.scop)
	c:RegisterEffect(e3)
end
c74892653.material_type=TYPE_SYNCHRO
-- 效果①的发动条件函数：必须是对方进行特殊召唤，且当前不在连锁处理中（连锁0）
function c74892653.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤的玩家是否为对方，且当前连锁数是否为0（即非效果处理中进行的特殊召唤）
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 过滤墓地中可以作为代替解放除外的卡片
function c74892653.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(84012625,tp)
end
-- 效果①的Cost（解放）处理函数，支持使用墓地中特定卡片代替解放
function c74892653.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中满足代替解放条件的卡片组
	local g=Duel.GetMatchingGroup(c74892653.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then return #g>0 end
	local tc
	if #g>1 then
		-- 提示玩家选择要解放的卡或代替解放而除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84012625,0))  --"请选择要解放或代替解放除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	local te=tc:IsHasEffect(84012625,tp)
	if te then
		-- 将代替解放的卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 解放自身作为发动的Cost
		Duel.Release(tc,REASON_COST)
	end
end
-- 效果①的Target（目标）处理函数，设置无效召唤和破坏的操作信息
function c74892653.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效特殊召唤的操作信息，涉及卡片为即将特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置破坏的操作信息，涉及卡片为即将特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果①的Operation（效果处理）函数：无效特殊召唤并破坏，同时给自身注册一个回合结束时苏生的标记
function c74892653.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效怪兽的特殊召唤
	Duel.NegateSummon(eg)
	-- 破坏那些特殊召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
	e:GetHandler():RegisterFlagEffect(74892653,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的Target（目标）处理函数：检查是否带有效果①适用的标记，且自身可以特殊召唤
function c74892653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否在本回合适用过①的效果（通过Flag标记判断），且自己场上有空余的怪兽区域
	if chk==0 then return c:GetFlagEffect(74892653)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的Operation（效果处理）函数：将自身从墓地特殊召唤
function c74892653.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的这张卡表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件函数：表侧表示的这张卡因战斗或对方的效果从场上离开
function c74892653.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤额外卡组中满足条件的卡：8星以下的「战士」同调怪兽，且可以被特殊召唤
function c74892653.filter(c,e,tp)
	return c:IsSetCard(0x66) and c:IsLevelBelow(8) and c:IsType(TYPE_SYNCHRO)
		-- 检查该怪兽是否能以同调召唤的方式特殊召唤，且额外怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的Target（目标）处理函数：检查必须成为素材的限制，并确认额外卡组中存在可特殊召唤的怪兽
function c74892653.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为同调素材的卡片限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的「战士」同调怪兽
		and Duel.IsExistingMatchingCard(c74892653.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的Operation（效果处理）函数：从额外卡组选择1只满足条件的怪兽，当作同调召唤特殊召唤
function c74892653.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果不满足必须作为同调素材的卡片限制，则不能处理效果
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「战士」同调怪兽
	local g=Duel.SelectMatchingCard(tp,c74892653.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 尝试将选中的怪兽以同调召唤的方式表侧表示特殊召唤，若成功则进行后续处理
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
