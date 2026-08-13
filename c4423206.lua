--M.X－セイバー インヴォーカー
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。把1只战士族或兽战士族的地属性·4星怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c4423206.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只等级3的怪兽叠放来XYZ召唤（不限制素材种族/属性）。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。把1只战士族或兽战士族的地属性·4星怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(4423206,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c4423206.cost)
	e1:SetTarget(c4423206.sptg)
	e1:SetOperation(c4423206.spop)
	c:RegisterEffect(e1)
end
-- 取除1个超量素材是发动代价；chk==0时检查能否取除，实际发动时移除这张卡的1个超量素材。
function c4423206.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义可特殊召唤的怪兽条件：战士族或兽战士族、地属性、等级4，并且可以表侧守备表示特殊召唤。
function c4423206.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR+RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动合法性检查：自己场上主要怪兽区有空位，且卡组中存在符合条件的怪兽（不取对象，处理时选卡）。
function c4423206.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时，先确认自己场上主要怪兽区有空格，供特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认卡组中存在至少1只满足 c4423206.spfilter 的怪兽。
		and Duel.IsExistingMatchingCard(c4423206.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 写入连锁操作信息：本效果将进行特殊召唤，预计从卡组特殊召唤1只怪兽，供其他卡发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：再次检查空格，提示并选择符合条件的怪兽，将其表侧守备表示特殊召唤；召唤成功后为它设置结束阶段破坏效果。
function c4423206.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若主要怪兽区已没有空格，则效果不适用，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 在选择卡之前，向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组选择1张满足 spfilter 的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c4423206.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选到怪兽且成功以表侧守备表示特殊召唤，则继续执行后续的结束阶段破坏绑定处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(4423206,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c4423206.descon)
		e1:SetOperation(c4423206.desop)
		-- 将这个结束阶段破坏的持续效果注册给tp方，使其在结束阶段时触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的发动条件：通过 fid 标记确认场上要破坏的怪兽仍是这次效果特殊召唤的那只；若标记已消失则效果重置，不再破坏。
function c4423206.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(4423206)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的实际处理函数：破坏那只被特殊召唤的怪兽。
function c4423206.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因（REASON_EFFECT）破坏该怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
