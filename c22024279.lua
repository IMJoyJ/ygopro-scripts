--オルターガイスト・リバイタリゼーション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只「幻变骚灵」连接怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。进行1只「幻变骚灵」怪兽的召唤。
local s,id,o=GetID()
-- 定义该卡的效果注册函数：创建并注册两个效果——①（特殊召唤墓地幻变骚灵连接怪兽）和②（除外自身后召唤幻变骚灵怪兽），二者共享1回合1次的发动次数限制
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己墓地1只「幻变骚灵」连接怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外才能发动。进行1只「幻变骚灵」怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	-- 设定②效果的发动代价为：把墓地中的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象过滤条件：对象必须是「幻变骚灵」连接怪兽，且可以被当前效果特殊召唤
function s.filter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x103)
end
-- ①效果的发动判定：取对象时检查选择的目标是否为自己墓地且满足条件；发动时检查自己有空位且墓地存在满足条件的对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区空格（用于特殊召唤）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只满足条件的「幻变骚灵」连接怪兽可以作为对象
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择要特殊召唤的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「幻变骚灵」连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息记录为特殊召唤：对象为选择的那只怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象并将其从墓地特殊召唤到自己场上（需满足关联和墓地限制）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然与该效果关联，且不受王家长眠之谷等使其无法从墓地特殊召唤的效果影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将选择的「幻变骚灵」连接怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果可选择的召唤对象条件：是「幻变骚灵」怪兽，且当前满足通常召唤条件（可忽略次数限制）
function s.sumfilter(c)
	return c:IsSetCard(0x103) and c:IsSummonable(true,nil)
end
-- ②效果的发动条件：手牌或自己场上存在至少1只可通常召唤的「幻变骚灵」怪兽，并设置操作信息为召唤
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或自己场上是否存在至少1只满足召唤条件的「幻变骚灵」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 将本次连锁的操作信息记录为进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果处理时，选择1只满足条件的「幻变骚灵」怪兽，并忽略通常召唤次数限制进行通常召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择要召唤的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌或自己场上选择1只满足条件的「幻变骚灵」怪兽作为要通常召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 以忽略通常召唤次数限制的方式将那只「幻变骚灵」怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
