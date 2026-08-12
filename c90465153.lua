--マナドゥム・プライムハート
-- 效果：
-- 调整1只以上＋光属性怪兽1只
-- ①：同调召唤的这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的调整数量的攻击。
-- ②：对方不能把用「末那愚子族」调整为素材作同调召唤的这张卡作为效果的对象。
-- ③：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的墓地·除外状态的1只「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、素材检查、特殊召唤成功时注册追加攻击与对象抗性、以及离场时特殊召唤墓地/除外怪兽的效果。
function s.initial_effect(c)
	-- 将卡号56099748（维萨斯-斯塔弗罗斯特）加入到该卡的关联卡片密码列表中，以便于其他卡片检索或确认。
	aux.AddCodeList(c,56099748)
	-- 设置同调召唤手续：光属性怪兽1只作为非调整，加上1只以上的调整怪兽。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- ①：同调召唤的这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的调整数量的攻击。②：对方不能把用「末那愚子族」调整为素材作同调召唤的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- ①：同调召唤的这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的调整数量的攻击。②：对方不能把用「末那愚子族」调整为素材作同调召唤的这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的墓地·除外状态的1只「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 同调素材检查函数，统计作为同调素材的调整怪兽数量，并检查是否存在「末那愚子族」调整怪兽，同时在素材调整数大于1时注册一个临时的标记效果。
function s.matcheck(e,c)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
	local check=0
	if g:IsExists(s.filter,1,nil) then
		check=1
	end
	e:SetLabel(ct,check)
	if ct>1 then
		-- ①：同调召唤的这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的调整数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：属于「末那愚子族」系列且是调整怪兽。
function s.filter(c)
	return c:IsType(TYPE_TUNER) and c:IsSetCard(0x190)
end
-- 注册效果的触发条件：这张卡是通过同调召唤特殊召唤成功的。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 注册效果的执行操作：根据同调素材的检查结果，若调整素材大于1则赋予追加攻击效果，若使用了「末那愚子族」调整则赋予不会成为对方效果对象的效果。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct,check=e:GetLabelObject():GetLabel()
	if ct>1 then
		-- ①：同调召唤的这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的调整数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	end
	if check>0 then
		-- ②：对方不能把用「末那愚子族」调整为素材作同调召唤的这张卡作为效果的对象。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))  --"「末那愚子族」调整为素材作同调召唤"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 设置不能成为对象效果的过滤函数，限制为对方玩家卡片的效果。
		e2:SetValue(aux.tgoval)
		c:RegisterEffect(e2)
	end
end
-- 特殊召唤效果的发动条件：同调召唤的表侧表示的这张卡，在自己控制下因对方从场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤条件：在墓地或除外状态，可以特殊召唤，且卡名为「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽。
function s.spfilter(c,e,tp)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- 特殊召唤效果的发动准备（检查与效果分类注册）：检查怪兽区域是否有空位，以及墓地或除外状态是否存在满足条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地或除外状态是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从自己的墓地或除外状态特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特殊召唤效果的执行操作：在有空位的情况下，让玩家从墓地或除外状态选择1只满足条件的怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地或除外状态选择1只满足条件且不受「王家长眠之谷」影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
