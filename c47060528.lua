--雷霆ノ魔軍神
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以「雷霆之魔军神」以外的自己墓地1只4星或4阶的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的卡名直到结束阶段当作「雷霆之魔军神」使用。
local s,id,o=GetID()
-- 初始化函数：登记卡片记载的卡名、设置XYZ召唤条件与苏生限制，并创建注册①特殊召唤和②卡名变更两个效果。
function s.initial_effect(c)
	-- 将本卡卡号id登记到卡片c的代码列表中，用于规则上识别“这个卡名的效果”以及同名卡。
	aux.AddCodeList(c,id)
	-- 为卡片c添加XYZ召唤手续，使用任意2只4星怪兽叠放进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以「雷霆之魔军神」以外的自己墓地1只4星或4阶的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的卡名直到结束阶段当作「雷霆之魔军神」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡名变更"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.codecon)
	e2:SetTarget(s.codetg)
	e2:SetOperation(s.codeop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：从这张卡上取除1个超量素材作为代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 特殊召唤对象过滤条件：不是「雷霆之魔军神」、等级4或阶级4、念动力族怪兽，且可以特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and (c:IsLevel(4) or c:IsRank(4)) and c:IsRace(RACE_PSYCHO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择判定：若是连锁中的对象确认，则验证对象在墓地、属于己方且满足筛选条件；若是发动时检查，则要求存在空余怪兽区域和可用对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足条件且能成为效果对象的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足条件的怪兽，并将其设定为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将特殊召唤的操作信息写入连锁，声明本连锁将进行特殊召唤（目标1张），供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，确认其仍与连锁相关且不受王家长眠之谷影响后，将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 验证目标怪兽仍与连锁相关，且不受「王家长眠之谷」效果影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽中不包含这张卡自身，即由其他怪兽特殊召唤成功诱发。
function s.codecon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
-- ②效果的对象过滤条件：目标为表侧表示怪兽，且卡名不是「雷霆之魔军神」。
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(id)
end
-- ②效果的目标选择处理：存在除这张卡以外的表侧表示且卡名非本卡名的怪兽时，选择其中1张为对象；连锁中则验证对象合法性。
function s.codetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.codefilter(chkc) and chkc~=c end
	-- 检查场上是否存在除这张卡以外的、满足codefilter条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 让玩家从场上满足条件的表侧表示怪兽中选择1张，作为②效果的对象。
	local g=Duel.SelectTarget(tp,s.codefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
-- ②效果处理：若对象仍与连锁相关、表侧表示且是怪兽，则给对象赋予持续到结束阶段的“卡名当作「雷霆之魔军神」”效果。
function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽的卡名直到结束阶段当作「雷霆之魔军神」使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(id)
		tc:RegisterEffect(e1)
	end
end
