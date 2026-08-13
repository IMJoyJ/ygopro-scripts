--湖の乙女ヴィヴィアン
-- 效果：
-- 把这张卡作为同调素材的场合，不是战士族怪兽的同调召唤不能使用，被同调召唤使用的这张卡除外。
-- ①：这张卡召唤成功时，以自己墓地1只「圣骑士」通常怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只5星「圣骑士」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。
function c10736540.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是战士族怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c10736540.synlimit)
	c:RegisterEffect(e1)
	-- 被同调召唤使用的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c10736540.rmcon)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己墓地1只「圣骑士」通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10736540,0))  --"墓地苏生"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c10736540.target)
	e3:SetOperation(c10736540.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在的场合，以自己场上1只5星「圣骑士」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10736540,1))  --"这张卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTarget(c10736540.sptg)
	e4:SetOperation(c10736540.spop)
	c:RegisterEffect(e4)
end
-- 同调素材限制的判断函数：当候选素材c为nil时返回false；若c不是战士族怪兽则返回true，表示该卡不能作为这张卡的同调素材，从而限定这张卡只能用于战士族怪兽的同调召唤。
function c10736540.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WARRIOR)
end
-- 替代去墓地的条件：当这张卡作为同调召唤的素材被使用（原因同时包含REASON_MATERIAL和REASON_SYNCHRO）时，条件成立，使这张卡不进入墓地而改为除外。
function c10736540.rmcon(e)
	return bit.band(e:GetHandler():GetReason(),REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
-- ①效果的怪兽筛选条件：选择自己墓地里卡名含有「圣骑士」字段、且为通常怪兽、并且能够被当前效果特殊召唤的怪兽。
function c10736540.filter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件和对象合法性检查：chkc时确认对象是己方墓地的合法「圣骑士」通常怪兽；chk==0时确认自己场上主要怪兽区有空位，且墓地中存在至少1只符合筛选条件的怪兽。
function c10736540.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10736540.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有可用的空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足filter条件的「圣骑士」通常怪兽，且该怪兽可以成为效果对象。
		and Duel.IsExistingTarget(c10736540.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向己方玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足filter条件的「圣骑士」通常怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c10736540.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本连锁将进行特殊召唤，特殊召唤对象为刚选择的怪兽g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得效果对象，若对象仍与效果关联，则将其表侧表示特殊召唤到己方场上。
function c10736540.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的第一个效果对象，即被选中的墓地「圣骑士」通常怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的怪兽筛选条件：选择自己场上表侧表示、等级为5、且卡名含有「圣骑士」字段的怪兽。
function c10736540.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsLevel(5)
end
-- ②效果的发动条件和对象合法性检查：chkc时确认对象是己方场上的表侧表示5星「圣骑士」怪兽；chk==0时确认自己主要怪兽区有空位、这张卡自身可以从墓地特殊召唤，且场上存在至少1只符合筛选条件的对象。
function c10736540.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c10736540.spfilter(chkc) end
	-- 检查自己场上主要怪兽区是否有可用的空格，用于后续从墓地特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少1只表侧表示且等级为5的「圣骑士」怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c10736540.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向己方玩家显示选择提示，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示、等级5的「圣骑士」怪兽作为效果对象。
	Duel.SelectTarget(tp,c10736540.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，声明本连锁将进行特殊召唤，特殊召唤对象为e:GetHandler()即这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：取对象，若对象变成里侧表示、与效果失去关联、免疫此效果或等级已为1则终止处理；否则先降低对象1星，若这张卡仍与效果关联，则将其从墓地特殊召唤。
function c10736540.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被选择的对象，即自己场上的5星「圣骑士」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsLevel(1) then return end
	local c=e:GetHandler()
	-- 那只怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-1)
	tc:RegisterEffect(e1)
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
