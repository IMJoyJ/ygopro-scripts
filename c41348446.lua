--デトネーション・コード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「拓扑」连接怪兽存在的场合，以连接怪兽以外的自己墓地1只龙族·机械族·电子界族的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡从魔法与陷阱区域除外的场合，下个回合的准备阶段才能发动。这张卡在自己场上盖放。
function c41348446.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「拓扑」连接怪兽存在的场合，以连接怪兽以外的自己墓地1只龙族·机械族·电子界族的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41348446,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,41348446)
	e2:SetCondition(c41348446.spcon)
	e2:SetTarget(c41348446.sptg)
	e2:SetOperation(c41348446.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡从魔法与陷阱区域除外的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(c41348446.spreg)
	c:RegisterEffect(e3)
	-- 下个回合的准备阶段才能发动。这张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41348446,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1,41348447)
	e4:SetCondition(c41348446.setcon)
	e4:SetTarget(c41348446.settg)
	e4:SetOperation(c41348446.setop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 定义过滤条件：判断怪兽是否为表侧表示、连接怪兽且属于「拓扑」系列（卡号含有0x16e对应字段）。
function c41348446.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x16e)
end
-- ①效果的发动条件：确认自己场上存在至少1只满足cfilter（表侧表示·拓扑连接怪兽）的怪兽。
function c41348446.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 使用Duel.IsExistingMatchingCard检查自己场上是否存在1张满足cfilter的卡片，作为发动①效果的前提。
	return Duel.IsExistingMatchingCard(c41348446.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义可选择对象的过滤条件：对象位于墓地、是龙族/机械族/电子界族、暗属性、不是连接怪兽，且能够被当前效果特殊召唤。
function c41348446.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE+RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_DARK)
		and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标选择函数：在指定对象时校验其位于自己墓地且满足spfilter；在效果发动合法性检查时确认有可用怪兽区且墓地存在满足条件的对象。
function c41348446.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41348446.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空闲的主要怪兽区用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足spfilter且能够成为当前效果对象的卡。
		and Duel.IsExistingTarget(c41348446.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向己方玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张满足spfilter的怪兽作为效果对象，同时将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c41348446.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁的操作信息：将要特殊召唤的对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理函数：取得之前选择的对象，如果该对象仍与该效果关联（没有中途离场等），则将其特殊召唤。
function c41348446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡（即特殊召唤对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的辅助记录处理：当这张卡从魔法与陷阱区域除外时，记录下个回合，并给这张卡注册标记，以备②效果在准备阶段发动时判定。
function c41348446.spreg(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsPreviousLocation(LOCATION_SZONE) then
		-- 在e3的Label中记录“当前回合数+1”，用于表示下个回合。
		e:SetLabel(Duel.GetTurnCount()+1)
		e:GetHandler():RegisterFlagEffect(41348446,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- ②效果的发动条件：当前回合数等于之前记录的回合数，且该卡带有对应的除外标记，即满足“这张卡从魔法与陷阱区域除外的场合，下个回合的准备阶段”。
function c41348446.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：e3记录的回合数等于当前回合，并且该卡的flag标记计数大于0。
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(41348446)>0
end
-- ②效果发动时的目标检查：确认这张卡可以被盖放；如果可以，则登记本处理要将这张卡从除外区盖放。
function c41348446.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 登记操作信息：效果处理时这张卡将从除外区离开（被盖放到场上）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理函数：取得效果持有卡，若该卡仍与效果关联，则将其盖放到自己场上。
function c41348446.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上盖放（魔法与陷阱区域）。
		Duel.SSet(tp,c)
	end
end
