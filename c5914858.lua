--調獄神ジュノーラ
-- 效果：
-- 调整＋调整以外的怪兽2只
-- 这张卡同调召唤的场合，可以把自己的中央的主要怪兽区域1只怪兽当作调整使用。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。对方场上的全部表侧表示卡的效果无效化。
-- ②：自己·对方回合可以发动。和自己场上的「耀圣」怪兽相同纵列的对方场上的全部怪兽直到回合结束时不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 初始化效果：注册同调召唤手续、①效果（同调召唤成功时无效对方场上全部表侧表示卡）和②效果（自由时点使与自己场上「耀圣」怪兽同纵列的对方怪兽不能作为特殊召唤素材）。
function s.initial_effect(c)
	-- 注册同调召唤手续：需要1只满足s.matfilter条件的怪兽作为调整，以及2只调整以外的怪兽。
	aux.AddSynchroMixProcedure(c,s.matfilter,nil,nil,aux.NonTuner(nil),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。对方场上的全部表侧表示卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合可以发动。和自己场上的「耀圣」怪兽相同纵列的对方场上的全部怪兽直到回合结束时不能作为融合·同调·超量·连接召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"不能作为素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
end
-- 过滤同调素材中的调整怪兽：必须是调整怪兽，或者是自己中央主要怪兽区域（第2格）的怪兽（当作调整使用）。
function s.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:GetSequence()==2
end
-- 检查发动条件：此卡是否是通过同调召唤特殊召唤成功的。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的发动准备：检查对方场上是否存在可无效的表侧表示卡片，并设置操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以被无效的表侧表示卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以被无效的表侧表示卡片。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：在连锁处理中将无效对方场上这些卡的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的效果处理：使对方场上全部表侧表示卡的效果无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前对方场上所有可以被无效的表侧表示卡片。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 遍历所有获取到的对方场上的表侧表示卡片。
	for tc in aux.Next(g) do
		-- 使与目标卡片相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示卡的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示卡的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对方场上的全部表侧表示卡的效果无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 过滤属于指定玩家控制且位于主要怪兽区域的怪兽。
function s.nsfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 过滤自己场上表侧表示的「耀圣」怪兽，且其相同纵列存在对方场上的怪兽。
function s.cfilter(c,tp)
	local chk=c:GetColumnGroup():IsExists(s.nsfilter,1,nil,1-tp)
	return c:IsFaceup() and c:IsSetCard(0x1d8) and chk
end
-- ②效果的发动准备：检查自己场上是否存在符合条件的「耀圣」怪兽。
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「耀圣」怪兽，且其相同纵列存在对方场上的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果的效果处理：使和自己场上「耀圣」怪兽相同纵列的对方场上全部怪兽直到回合结束时不能作为融合·同调·超量·连接召唤的素材。
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有符合条件的「耀圣」怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if g:GetCount()==0 then return end
	local sg=Group.CreateGroup()
	-- 遍历这些「耀圣」怪兽，以获取它们相同纵列的对方怪兽。
	for tc in aux.Next(g) do
		local tg=tc:GetColumnGroup():Filter(s.nsfilter,nil,1-tp)
		Group.Merge(sg,tg)
	end
	-- 遍历所有与「耀圣」怪兽相同纵列的对方场上的怪兽。
	for tc in aux.Next(sg) do
		-- 不能作为融合·同调·超量·连接召唤的素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(s.fuslimit)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetDescription(aux.Stringid(id,2))  --"「调狱神 朱诺拉」效果适用中"
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e5)
	end
end
-- 限制融合素材的判定函数：当召唤类型为融合召唤时返回true，表示不能作为融合素材。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
