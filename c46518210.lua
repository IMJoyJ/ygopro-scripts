--溟界神－ネフェルアビス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的状态，从自己或对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不是爬虫类族怪兽不能特殊召唤。
-- ②：这张卡是已从墓地特殊召唤的场合，以「溟界神-涅斐尔阿比斯」以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册e0墓地存在标记辅助效果、e1为①效果的诱发效果（墓地发动）、e2为②效果的起动效果；e1与e2各自有1回合1次的限制。
function s.initial_effect(c)
	-- 为这张卡注册“已在墓地存在”的标记检测效果（aux.AddThisCardInGraveAlreadyCheck），用于在“这张卡在墓地存在的状态”的场合型效果中进行正确的状态记录与判定。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在墓地存在的状态，从自己或对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不是爬虫类族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡是已从墓地特殊召唤的场合，以「溟界神-涅斐尔阿比斯」以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.gscon)
	e2:SetTarget(s.gstg)
	e2:SetOperation(s.gsop)
	c:RegisterEffect(e2)
end
-- 筛选条件：判定一张怪兽是否从手卡或卡组被送去墓地（且是怪兽卡），同时排除由指定效果se导致的送墓，防止①效果被自身操作或同一效果循环触发。
function s.cfilter(c,se)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ①的发动条件：从e1的标记对象（墓地存在判定效果）中取得se，检查本次送去墓地的怪兽群eg中是否存在至少1只满足cfilter的怪兽（从手卡·卡组送去墓地且非本效果自身导致）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,e:GetHandler(),se)
end
-- ①的发动时点合法性检查：需要自己场上存在可用的主要怪兽区空格，且这张卡在墓地中能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否还有可用的主要怪兽区空格，以确定能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理会将这张卡特殊召唤（数量1），供连锁及相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联则将其特殊召唤；随后给当前玩家注册一个自肃效果：到下个结束阶段为止不能特殊召唤爬虫类族以外的怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与本次效果关联（即效果处理时仍在墓地），则将它以表侧表示特殊召唤到自己的场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
	-- 这个效果的发动后，直到下个回合的结束时自己不是爬虫类族怪兽不能特殊召唤。②：这张卡是已从墓地特殊召唤的场合，以「溟界神-涅斐尔阿比斯」以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将上述自肃效果注册给tp玩家，使tp玩家自此受到“不能特殊召唤非爬虫类族怪兽”的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的禁止条件：如果目标怪兽不是爬虫类族，则不允许被特殊召唤。
function s.splim(e,c)
	return not c:IsRace(RACE_REPTILE)
end
-- ②的发动条件：这张卡必须是从墓地特殊召唤上场（其召唤地点为墓地）时才能发动。
function s.gscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- ②对象筛选条件：从自己墓地中选择能够被特殊召唤、且卡名不是「溟界神-涅斐尔阿比斯」自身的怪兽。
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ②的取对象处理：若检查对象（chkc），则确认它位于自己墓地且满足筛选；若检查发动合法性（chk==0），则确认场上可用的主要怪兽区>0，且自己墓地存在符合条件的对象。
function s.gstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足s.filter且能成为效果对象的怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给出选择提示：请选择要特殊召唤的卡（将选择消息写入缓存）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp玩家从自己墓地中筛选满足条件的怪兽，选择1只作为效果对象并设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理会将对象g（1只怪兽）特殊召唤，供连锁及相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取出对象卡，若它仍与本次效果关联，则将其特殊召唤。
function s.gsop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其以表侧表示特殊召唤到自己的场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
