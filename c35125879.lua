--真竜皇の復活
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，①②的效果在同一连锁上不能发动。
-- ①：以自己墓地1只「真龙」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c35125879.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 这个卡名的①②③的效果1回合各能使用1次，①②的效果在同一连锁上不能发动。①：以自己墓地1只「真龙」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35125879,0))  --"墓地苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,35125879)
	e2:SetCost(c35125879.cost)
	e2:SetTarget(c35125879.sptg)
	e2:SetOperation(c35125879.spop)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35125879,1))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,35125880)
	e3:SetCondition(c35125879.sumcon)
	e3:SetCost(c35125879.cost)
	e3:SetTarget(c35125879.sumtg)
	e3:SetOperation(c35125879.sumop)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35125879,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,35125881)
	e4:SetCondition(c35125879.descon)
	e4:SetTarget(c35125879.destg)
	e4:SetOperation(c35125879.desop)
	c:RegisterEffect(e4)
end
-- 支付代价：检查本连锁是否已使用过①或②效果（通过玩家标志35125879），若未使用则注册该标志（连锁结束后重置），以此实现“①②的效果在同一连锁上不能发动”。
function c35125879.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：仅在玩家不存在标志35125879（即本连锁尚未发动过①或②）时才允许发动。
	if chk==0 then return Duel.GetFlagEffect(tp,35125879)==0 end
	-- 为玩家注册标志35125879，连锁结束时自动重置，标记本连锁已发动过①或②，使同一连锁内不能再发动另一个。
	Duel.RegisterFlagEffect(tp,35125879,RESET_CHAIN,0,1)
end
-- 特殊召唤的过滤函数：选择满足「真龙」字段、且可以以表侧守备表示由当前玩家特殊召唤的怪兽。
function c35125879.spfilter(c,e,tp)
	return c:IsSetCard(0xf9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①的发动条件与选对象：我方主要怪兽区有空位，且墓地存在符合条件的「真龙」怪兽；发动时选择其中1只作为对象。
function c35125879.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35125879.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有可用空格，确保特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足「真龙」且可特殊召唤的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c35125879.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出“选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「真龙」怪兽作为效果对象（同时自动成为连锁对象）。
	local g=Duel.SelectTarget(tp,c35125879.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为“特殊召唤1只怪兽”，供相关时点（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽以表侧守备表示特殊召唤；然后给己方附加“直到回合结束不能特殊召唤怪兽”的自肃效果。
function c35125879.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上（检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将自肃效果作为场地效果注册到玩家tp，使tp在回合结束前不能进行特殊召唤。
	Duel.RegisterEffect(e1,tp)
end
-- ②的发动条件：当前阶段为主要阶段1或2，且当前回合玩家不是自己，即“对方主要阶段”。
function c35125879.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前回合玩家不是tp且阶段是主阶1或主阶2，满足②的发动时机。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 上级召唤的过滤函数：选择手卡中属于「真龙」字段且可以解放1只以上怪兽进行表侧上级召唤的怪兽。
function c35125879.sumfilter(c)
	return c:IsSetCard(0xf9) and c:IsSummonable(true,nil,1)
end
-- ②的发动条件：手卡中存在可上级召唤的「真龙」怪兽；并设置操作信息为召唤。
function c35125879.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的「真龙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35125879.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息为“召唤1只怪兽”，供相关时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果处理：从手卡选择1只「真龙」怪兽进行表侧表示上级召唤（使用1只解放）。
function c35125879.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡选择1只满足条件的「真龙」怪兽，准备进行上级召唤。
	local g=Duel.SelectMatchingCard(tp,c35125879.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行通常召唤（上级召唤），忽略本回合通常召唤次数限制，至少使用1只解放。
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- ③的诱发条件：这张卡从魔法与陷阱区域被送去墓地（场合型，不遗漏时点）。
function c35125879.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- ③的发动条件：场上存在可作为对象的怪兽；发动时选择场上1只怪兽为对象。
function c35125879.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查双方主要怪兽区是否存在可作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为“破坏1只怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：将对象怪兽破坏。
function c35125879.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
