--究極竜魔導師
-- 效果：
-- 「青眼究极龙」（或者「青眼」怪兽×3）＋「混沌」仪式怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：对方把效果发动时才能发动（这个卡名的这个效果在1回合对魔法·陷阱·怪兽的效果每种各能发动1次）。那个发动无效并破坏。
-- ②：表侧表示的这张卡因对方从场上离开的场合才能发动。从自己的额外卡组·墓地把1只「青眼」怪兽或「混沌」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片添加融合素材代码列表，指定可作为融合素材的卡牌代码为23995346
	aux.AddMaterialCodeList(c,23995346)
	c:EnableReviveLimit()
	-- ①：对方把效果发动时才能发动（这个卡名的这个效果在1回合对魔法·陷阱·怪兽的效果每种各能发动1次）。那个发动无效并破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为融合召唤限制条件
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ②：表侧表示的这张卡因对方从场上离开的场合才能发动。从自己的额外卡组·墓地把1只「青眼」怪兽或「混沌」仪式怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(s.fcondition)
	e1:SetOperation(s.foperation)
	c:RegisterEffect(e1)
	-- 设置诱发即时效果①，当对方发动效果时触发，无效并破坏该发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 设置触发效果②，当此卡离开场上的时候发动，从额外卡组或墓地特殊召唤一只「青眼」怪兽或「混沌」仪式怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义融合素材过滤函数1，用于判断是否为「青眼究极龙」或可替代的融合素材
function s.ffilter1(c,fc)
	return c:IsFusionCode(23995346) or c:CheckFusionSubstitute(fc)
end
-- 定义融合素材过滤函数2，用于判断是否为「混沌」系列怪兽
function s.ffilter2(c)
	return c:IsFusionSetCard(0xdd) and c:IsType(TYPE_MONSTER)
end
-- 定义融合素材过滤函数3，用于判断是否为「混沌」仪式怪兽
function s.ffilter3(c)
	return c:IsFusionSetCard(0xcf) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL)
end
-- 定义融合素材通用过滤函数，综合以上三种过滤条件
function s.ffilter(c,fc)
	return c:IsCanBeFusionMaterial(fc) and (s.ffilter1(c,fc) or s.ffilter2(c) or s.ffilter3(c))
end
-- 定义融合组合检查函数，用于判断是否满足特定组合条件
function s.f2filter3(c,sg)
	return s.ffilter3(c) and sg:IsExists(s.ffilter2,3,c)
end
-- 定义融合检查函数，用于验证融合组合是否合法
function s.fcheck(sg,fc,tp,gc,chkf)
	local ct=#sg
	if ct~=2 and ct~=4 then return false end
	if gc and not sg:IsContains(gc) then return false end
	-- 检查是否存在调弦之魔术师效果影响
	if sg:IsExists(aux.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	-- 检查是否满足必须成为融合素材的条件
	if not aux.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	-- 检查是否有足够的召唤区域
	if not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0) then return false end
	-- 检查是否满足额外的融合检查条件
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,sg,fc)
		-- 检查是否满足额外的融合目标检查条件
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,sg,fc) then return false end
	if ct==2 then
		-- 使用辅助函数验证是否满足特定融合组合条件
		return aux.gffcheck(sg,s.ffilter1,fc,s.ffilter3,nil)
	else
		return sg:IsExists(s.f2filter3,1,nil,sg)
	end
end
-- 定义融合条件函数，用于判断是否满足融合召唤条件
function s.fcondition(e,g,gc,chkf)
	local tp=e:GetHandlerPlayer()
	-- 当没有提供融合素材组时，检查是否满足必须成为融合素材的条件
	if g==nil then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(s.ffilter,nil,c)
	if gc and not mg:IsContains(gc) then return false end
	return mg:CheckSubGroup(s.fcheck,2,4,c,tp,gc,chkf)
end
-- 定义融合操作函数，用于选择并设置融合素材
function s.foperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(s.ffilter,nil,c)
	-- 提示玩家选择融合素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g=mg:SelectSubGroup(tp,s.fcheck,false,2,4,c,tp,gc,chkf)
	-- 设置融合素材组
	Duel.SetFusionMaterial(g)
end
-- 定义终极融合检查函数，用于判断是否满足特定融合条件
function s.ultimate_fusion_check(tp,sg,fc)
	-- 验证融合组合是否为「青眼究极龙」与「混沌」仪式怪兽的组合
	return #sg==2 and aux.gffcheck(sg,Card.IsFusionCode,23995346,s.ffilter3,nil)
end
-- 定义效果①的发动条件函数
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动效果且未被破坏
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		-- 判断是否为魔法效果且未发动过
		and ((re:IsActiveType(TYPE_MONSTER) and Duel.GetFlagEffect(tp,id)==0)
		-- 判断是否为陷阱效果且未发动过
		or (re:IsActiveType(TYPE_SPELL) and Duel.GetFlagEffect(tp,id+o)==0)
		-- 判断是否为怪兽效果且未发动过
		or (re:IsActiveType(TYPE_TRAP) and Duel.GetFlagEffect(tp,id+o*2)==0))
end
-- 定义效果①的目标函数
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置操作信息，表示将无效并破坏对方发动的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:IsActiveType(TYPE_MONSTER) then
		-- 注册标识效果，标记该回合已发动过魔法效果
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 注册提示效果，提示玩家该回合已发动过魔法效果
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 注册标识效果，标记该回合已发动过魔法效果
		Duel.RegisterEffect(e1,tp)
	elseif re:IsActiveType(TYPE_SPELL) then
		-- 注册标识效果，标记该回合已发动过魔法效果
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		-- 注册提示效果，提示玩家该回合已发动过陷阱效果
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
	elseif re:IsActiveType(TYPE_TRAP) then
		-- 注册标识效果，标记该回合已发动过陷阱效果
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		-- 注册提示效果，提示玩家该回合已发动过陷阱效果
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,5))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
	end
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将破坏对方发动的效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果①的处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效对方发动的效果并破坏其卡牌
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动的效果卡牌
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义效果②的发动条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 定义特殊召唤过滤函数，用于筛选可特殊召唤的「青眼」或「混沌」怪兽
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0xdd) or c:IsSetCard(0xcf) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否满足墓地召唤条件
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断是否满足额外卡组召唤条件
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 定义效果②的目标函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 定义效果②的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
