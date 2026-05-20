--天上天下百鬼羅刹
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「哥布林」怪兽的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只4星以下的「哥布林」怪兽特殊召唤。
-- ③：这张卡被送去墓地的场合，以场上1张卡为对象才能发动。那张卡作为自己场上1只「哥布林」超量怪兽的超量素材。
local s,id,o=GetID()
-- 初始化卡片效果，注册不用解放召唤、召唤/特殊召唤时从卡组特召哥布林、送墓时将场上卡作为哥布林超量素材的效果。
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有「哥布林」怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只4星以下的「哥布林」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以场上1张卡为对象才能发动。那张卡作为自己场上1只「哥布林」超量怪兽的超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"作为超量素材"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.mttg)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上里侧表示的怪兽，或者不是「哥布林」字段的怪兽。
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xac)
end
-- 不用解放作召唤的条件判断函数。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否是不需要解放、自身等级在5星以上且自己场上有可用的怪兽区域。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否没有怪兽，或者只有表侧表示的「哥布林」怪兽。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 过滤条件：卡组中4星以下的「哥布林」怪兽，且能被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 召唤·特殊召唤成功时发动效果的靶向/可行性检查函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的「哥布林」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 召唤·特殊召唤成功时发动效果的处理函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「哥布林」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：可以作为超量素材的场上的卡，且自己场上存在可以叠放它的「哥布林」超量怪兽。
function s.filter1(c,e,tp)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
		-- 检查自己场上是否存在除该卡以外的、满足条件的「哥布林」超量怪兽。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤条件：自己场上表侧表示的「哥布林」超量怪兽。
function s.filter2(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xac)
end
-- 送墓时发动效果的靶向/可行性检查函数。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter1(chkc,e,tp) end
	-- 检查场上是否存在可以作为超量素材的卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择场上1张卡作为效果的对象。
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
end
-- 送墓时发动效果的处理函数。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要重叠素材的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「哥布林」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,tc,e)
	if g:GetCount()>0 then
		-- 选中该超量怪兽并显示选择动画。
		Duel.HintSelection(g)
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将作为对象的卡原本拥有的超量素材因规则送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		tc:CancelToGrave()
		-- 将作为对象的卡重叠在选择的超量怪兽下面作为超量素材。
		Duel.Overlay(g:GetFirst(),Group.FromCards(tc))
	end
end
