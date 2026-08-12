--ベアルクティ－ポーラ＝スター
-- 效果：
-- 这张卡不能同调召唤，等级差直到1为止从自己场上把调整1只和调整以外的怪兽1只送去墓地的场合才能特殊召唤。
-- ①：把这张卡和自己的手卡·场上1只8星「北极天熊」怪兽解放才能发动。把1只7星「北极天熊」同调怪兽无视召唤条件从额外卡组特殊召唤。这个效果特殊召唤的怪兽得到以下效果。
-- ●对方不能把从额外卡组特殊召唤的持有等级的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤限制、特殊召唤规则以及解放自身和手卡·场上8星「北极天熊」怪兽从额外卡组特殊召唤7星「北极天熊」同调怪兽的起动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 等级差直到1为止从自己场上把调整1只和调整以外的怪兽1只送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.sprcon)
	e2:SetTarget(s.sprtg)
	e2:SetOperation(s.sprop)
	c:RegisterEffect(e2)
	-- ①：把这张卡和自己的手卡·场上1只8星「北极天熊」怪兽解放才能发动。把1只7星「北极天熊」同调怪兽无视召唤条件从额外卡组特殊召唤。这个效果特殊召唤的怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤自身场上表侧表示、有等级且可以送去墓地的怪兽
function s.tgrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 检查怪兽组中是否存在与指定怪兽等级差为1的另一只怪兽
function s.mnfilter(c,g)
	return g:IsExists(s.mnfilter2,1,c,c)
end
-- 计算并检查两只怪兽的等级差是否绝对值为1
function s.mnfilter2(c,mc)
	return math.abs(c:GetLevel()-mc:GetLevel())==1
end
-- 检查选取的怪兽组是否满足特殊召唤素材条件（1只调整和1只非调整、等级差为1，且能腾出额外怪兽区域）
function s.fselect(g,tp,sc)
	-- 检查选取的卡片数量是否为2张，且包含1只调整和1只非调整怪兽
	return g:GetCount()==2 and g:IsExists(Card.IsType,1,nil,TYPE_TUNER) and g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
		-- 检查选取的怪兽等级差是否为1，且在这些怪兽送去墓地后有可用的额外怪兽区域
		and g:IsExists(s.mnfilter,1,nil,g) and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤规则的Condition函数：检查自己场上是否存在满足特殊召唤条件的怪兽组合
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可以送去墓地的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.tgrfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(s.fselect,2,2,tp,c)
end
-- 特殊召唤规则的Target函数：玩家选择用于特殊召唤的2只怪兽，并将其保存在效果对象中
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可以送去墓地的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.tgrfilter,tp,LOCATION_MZONE,0,nil)
	-- 给玩家发送选择要送去墓地的卡片的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数：执行特殊召唤的动作，将选定的怪兽送去墓地
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tg=e:GetLabelObject()
	-- 将选定的怪兽作为特殊召唤的素材送去墓地
	Duel.SendtoGrave(tg,REASON_SPSUMMON)
	tg:DeleteGroup()
end
-- 检查卡片是否具有代替解放的效果（如「北极天熊」相关魔法陷阱卡的墓地代替除外效果）
function s.checkrelrep(c,tp)
	return c:IsHasEffect(16471775,tp) or c:IsHasEffect(89264428,tp)
end
-- 过滤手卡或场上可以被解放的8星「北极天熊」怪兽
function s.rfilter(c,tp)
	return c:IsLevel(8) and c:IsSetCard(0x163) and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤墓地中可以除外以代替解放的卡片
function s.excostfilter(c,tp)
	return c:IsAbleToRemove() and s.checkrelrep(c,tp)
end
-- 检查选定的解放卡片（或代替卡片）是否能满足额外卡组特殊召唤的条件
function s.costfilter(c,handler,e,tp)
	if not handler:IsReleasable() and not s.excostfilter(c,tp) then return false end
	local excg=s.checkrelrep(c,tp) and c or Group.FromCards(c,handler)
	-- 检查额外卡组是否存在可以特殊召唤的7星「北极天熊」同调怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,excg)
end
-- 过滤额外卡组中可以无视召唤条件特殊召唤的7星「北极天熊」同调怪兽
function s.spfilter(c,e,tp,g)
	return c:IsLevel(7) and c:IsSetCard(0x163) and c:IsType(TYPE_SYNCHRO)
		-- 检查在素材离场后是否有可用的额外怪兽区域，且该怪兽可以无视召唤条件特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 起动效果的Cost函数：支付发动效果的cost（解放自身和手卡·场上1只8星「北极天熊」怪兽，或使用墓地卡片代替解放）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己手卡·场上可以解放的8星「北极天熊」怪兽
	local g1=Duel.GetReleaseGroup(tp,true):Filter(s.rfilter,c,tp)
	-- 获取墓地中可以除外以代替解放的卡片
	local g2=Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	g1:Merge(g2)
	if chk==0 then return g1:IsExists(s.costfilter,1,c,c,e,tp) end
	-- 给玩家发送选择要解放的卡片的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g1:FilterSelect(tp,s.costfilter,1,1,c,c,e,tp)
	local tc=rg:GetFirst()
	local te=tc:IsHasEffect(16471775,tp) or tc:IsHasEffect(89264428,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将墓地的代替卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		rg:AddCard(c)
		-- 强制使用类似暗影敌托邦等卡片的代替解放效果次数
		aux.UseExtraReleaseCount(rg,tp)
		-- 解放选定的卡片作为发动效果的cost
		Duel.Release(rg,REASON_COST)
	end
end
-- 起动效果的Target函数：检查特殊召唤效果的目标是否合法，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 或者检查额外卡组是否存在可以特殊召唤的7星「北极天熊」同调怪兽
		or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil) end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 起动效果的Operation函数：从额外卡组无视召唤条件特殊召唤1只7星「北极天熊」同调怪兽，并赋予其对方不能发动从额外卡组特殊召唤的有等级怪兽效果的永续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择要特殊召唤的卡片的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只满足特殊召唤条件的7星「北极天熊」同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 then
		local tc=g:GetFirst()
		-- 尝试将选定的怪兽无视召唤条件表侧表示特殊召唤，若成功则执行后续处理
		if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
			local c=e:GetHandler()
			-- 这个效果特殊召唤的怪兽得到以下效果。●对方不能把从额外卡组特殊召唤的持有等级的怪兽的效果发动。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,1)
			e1:SetValue(s.aclimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			if not tc:IsType(TYPE_EFFECT) then
				-- 这个效果特殊召唤的怪兽得到以下效果。●对方不能把从额外卡组特殊召唤的持有等级的怪兽的效果发动。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_ADD_TYPE)
				e2:SetValue(TYPE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2,true)
			end
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"「北极天熊-北极星」效果适用中"
		end
	end
end
-- 限制对方不能发动从额外卡组特殊召唤的、持有等级的怪兽的效果
function s.aclimit(e,re)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLevelAbove(1) and rc:IsSummonLocation(LOCATION_EXTRA)
end
