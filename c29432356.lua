--智天の神星龍
-- 效果：
-- ←5 【灵摆】 5→
-- 「智天之神星龙」的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组选1只「神数」灵摆怪兽表侧表示加入自己的额外卡组，这张卡的灵摆刻度直到回合结束时变成和那只灵摆怪兽的灵摆刻度相同。
-- 【怪兽效果】
-- 这张卡不能通常召唤。这张卡在额外卡组表侧表示存在，把包含「神数」怪兽3只以上的自己场上的怪兽全部解放的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「神数」怪兽灵摆召唤。
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。从卡组把1只「神数」怪兽特殊召唤。
function c29432356.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从卡组选1只「神数」灵摆怪兽表侧表示加入自己的额外卡组，这张卡的灵摆刻度直到回合结束时变成和那只灵摆怪兽的灵摆刻度相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29432356,0))  --"「神数」灵摆怪兽加入自己的额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,29432357)
	e1:SetTarget(c29432356.sctg)
	e1:SetOperation(c29432356.scop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。这张卡在额外卡组表侧表示存在，把包含「神数」怪兽3只以上的自己场上的怪兽全部解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 这张卡在额外卡组表侧表示存在，把包含「神数」怪兽3只以上的自己场上的怪兽全部解放的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(c29432356.hspcon)
	e3:SetOperation(c29432356.hspop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤成功的回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「神数」怪兽灵摆召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c29432356.penop)
	c:RegisterEffect(e4)
	-- ②：1回合1次，把自己场上1只怪兽解放才能发动。从卡组把1只「神数」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(29432356,3))  --"从卡组把1只「神数」怪兽特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c29432356.spcost)
	e5:SetTarget(c29432356.sptg)
	e5:SetOperation(c29432356.spop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于筛选满足条件的灵摆怪兽：类型为灵摆、种族为神数、且其左刻度不等于目标卡片的左刻度
function c29432356.scfilter(c,pc)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xc4)
		and c:GetLeftScale()~=pc:GetLeftScale()
end
-- 设置灵摆效果的目标函数，检查是否满足条件：在自己的卡组中存在至少1张符合条件的灵摆怪兽
function c29432356.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：在自己的卡组中存在至少1张符合条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29432356.scfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
	-- 设置操作信息，表示将要将1张卡从卡组加入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的处理函数，执行将选中的灵摆怪兽加入额外卡组，并修改自身灵摆刻度
function c29432356.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要加入额外卡组的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29432356,1))  --"请选择要加入自己的额外卡组的卡"
	-- 从卡组中选择1张符合条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c29432356.scfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	-- 判断选中的灵摆怪兽是否成功加入额外卡组
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)>0 then
		-- 创建一个效果，用于修改自身左刻度为选中灵摆怪兽的左刻度
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(tc:GetLeftScale())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(tc:GetRightScale())
		c:RegisterEffect(e2)
	end
end
-- 特殊召唤条件的判断函数，检查是否满足特殊召唤条件：场上存在至少3只神数怪兽且可以解放所有可解放的怪兽
function c29432356.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上的所有怪兽组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取玩家可解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return (g:GetCount()>0 or rg:GetCount()>0) and g:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==g:GetCount()
		and g:FilterCount(Card.IsSetCard,nil,0xc4)>=3
		-- 检查在当前状态下是否可以将目标怪兽特殊召唤到额外卡组
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
-- 特殊召唤的处理函数，执行解放操作
function c29432356.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取玩家可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 执行解放操作，将指定怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 灵摆召唤成功后的处理函数，为玩家添加一次额外的灵摆召唤机会
function c29432356.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为玩家添加一次额外的灵摆召唤机会
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29432356,2))  --"使用「智天之神星龙」的效果灵摆召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,29432356)
	e2:SetValue(c29432356.pendvalue)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使效果生效
	Duel.RegisterEffect(e2,tp)
end
-- 返回值函数，判断目标怪兽是否为神数种族
function c29432356.pendvalue(e,c)
	return c:IsSetCard(0xc4)
end
-- 过滤函数，用于筛选满足条件的可解放怪兽：场上的怪兽或手牌中的怪兽
function c29432356.spcfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 设置特殊召唤的费用函数，检查是否满足费用条件并选择要解放的怪兽
function c29432356.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足费用条件：场上的可用区域数量大于-1且存在可解放的怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c29432356.spcfilter,1,nil,ft,tp) end
	-- 从可解放的怪兽中选择1张进行解放
	local sg=Duel.SelectReleaseGroup(tp,c29432356.spcfilter,1,1,nil,ft,tp)
	-- 执行解放操作，将指定怪兽解放作为费用
	Duel.Release(sg,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的神数怪兽：种族为神数且可以特殊召唤
function c29432356.spfilter(c,e,tp)
	return c:IsSetCard(0xc4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的目标函数，检查是否满足条件：在自己的卡组中存在至少1张符合条件的神数怪兽
function c29432356.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：在自己的卡组中存在至少1张符合条件的神数怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29432356.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤的处理函数，执行从卡组特殊召唤怪兽的操作
function c29432356.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的神数怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张符合条件的神数怪兽
	local g=Duel.SelectMatchingCard(tp,c29432356.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作，将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
