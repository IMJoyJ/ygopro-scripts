--オッドアイズ・ソルブレイズ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是灵摆怪兽不能特殊召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把2只其他的融合·同调·超量·灵摆怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 定义卡的初始化：添加同调召唤手续和苏生限制，注册①的诱发效果（特殊召唤时从额外卡组特召灵摆并附加自肃）与②的墓地起动效果（除外2只怪兽自我苏生），两者共用1回合1次的次数限制。
function s.initial_effect(c)
	-- 添加同调召唤手续：以1只调整为素材，加上调整以外的怪兽1只以上（此处不限制调整和调整外怪兽的具体种族/属性）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是灵摆怪兽不能特殊召唤。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的场合，从自己墓地把2只其他的融合·同调·超量·灵摆怪兽除外才能发动。这张卡特殊召唤。
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
-- 定义筛选条件：额外卡组表侧表示的灵摆怪兽，必须能被tp以表侧表示特殊召唤，并且从额外卡组特殊召唤时有可用区域。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 额外检查通过GetLocationCountFromEx是否存在可用区域（例如额外怪兽区或连接箭头指向的主怪兽区），确保额外卡组的怪兽有格子可出。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动目标判定：若额外卡组存在满足spfilter的灵摆怪兽则可发动，并设置操作信息为特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查额外卡组表侧是否存在至少1张满足s.spfilter的灵摆怪兽，用于判断是否满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记效果处理为特殊召唤，处理对象为额外卡组，数量1，使其他卡/效果能正确关联该特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①处理：选择1张额外卡组的灵摆怪兽特殊召唤，成功后给那张怪兽附加自肃：只要它在自己场上表侧表示存在，自己不能特殊召唤非灵摆怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 筛选并选择1张额外卡组表侧且符合s.spfilter的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选择的灵摆怪兽表侧表示特殊召唤，返回值不等于0表示召唤成功，才继续附加自肃效果。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是灵摆怪兽不能特殊召唤。②：这张卡在墓地存在的场合，从自己墓地把2只其他的融合·同调·超量·灵摆怪兽除外才能发动。这张卡特殊召唤。
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
-- 自肃效果的条件：效果附加的灵摆怪兽的控制者是效果的发动玩家（即异色眼日焰龙的控制者），确保自肃只在该怪兽在自己场上表侧时生效。
function s.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 自肃的禁止特殊召唤判定：要特殊召唤的怪兽的原始类型中不包含灵摆（即非灵摆怪兽）时禁止召唤。
function s.splimit(e,c)
	return c:GetOriginalType()&TYPE_PENDULUM~=TYPE_PENDULUM
end
-- 定义②效果代价的筛选：墓地里持有者是当前玩家的融合·同调·超量·灵摆怪兽，并且可以作为代价除外。
function s.rfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM) and c:IsAbleToRemoveAsCost()
end
-- ②效果的费用：从自己墓地选择2只其他（不含这张卡自身）的融合·同调·超量·灵摆怪兽除外才能发动。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少2张满足s.rfilter且不是e:GetHandler()的卡，用于决定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 弹出“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2张满足条件的卡（排除自身）作为代价。
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选中的2张卡以表侧表示除外，作为发动②效果的费用。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动目标判定：自己场上有可用主怪兽区，且墓地中的这张卡自身能够被特殊召唤（满足苏生限制等）。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位（至少1个），因为这张卡要从墓地特殊召唤到主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：特殊召唤对象为本卡（e:GetHandler()），数量为1，用于连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若仍有空位，且这张卡仍与效果关联且不受王家长眠之谷影响，则将其表侧表示特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认主要怪兽区仍有空位，若无空位则结束处理（不进行特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 确认这张卡仍与发动时的效果有联系（未被除外或移动）且未受王家长眠之谷无效，防止墓地效果被无效。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将墓地中的这张卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
