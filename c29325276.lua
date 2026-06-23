--オッドアイズ・ソルブレイズ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是灵摆怪兽不能特殊召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把2只其他的融合·同调·超量·灵摆怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤程序并启用复活限制，注册两个效果：①特殊召唤成功时从额外卡组特殊召唤灵摆怪兽；②墓地时消耗2只融合/同调/超量/灵摆怪兽特殊召唤自己
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是灵摆怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从额外卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己墓地把2只其他的融合·同调·超量·灵摆怪兽除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
end
-- 定义用于筛选额外卡组中可特殊召唤的灵摆怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 检查是否有足够的额外卡组特殊召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果处理时的筛选目标，检查是否存在满足条件的灵摆怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，提示将要特殊召唤1只灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理特殊召唤灵摆怪兽的效果，选择并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选中的灵摆怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 创建一个永续效果，限制玩家不能特殊召唤非灵摆怪兽
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetCondition(s.splimitcon)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
	end
end
-- 设置限制效果的触发条件，仅当该效果的持有者控制该卡时生效
function s.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 设置限制效果的目标，禁止特殊召唤非灵摆怪兽
function s.splimit(e,c)
	return c:GetOriginalType()&TYPE_PENDULUM~=TYPE_PENDULUM
end
-- 定义用于筛选墓地中可除外的融合/同调/超量/灵摆怪兽的过滤函数
function s.rfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM) and c:IsAbleToRemoveAsCost()
end
-- 处理效果的费用，从墓地选择2只符合条件的怪兽除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外2只符合条件怪兽的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择2只符合条件的怪兽除外
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选中的怪兽除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理时的筛选目标，检查是否有足够的主怪兽区位置并可特殊召唤自己
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的主怪兽区位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，提示将要特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理墓地特殊召唤效果，检查条件并特殊召唤自己
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否有足够的主怪兽区位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查该卡是否与效果相关联且未受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
