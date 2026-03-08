--岩竜ベアロック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被对方破坏的场合，以这张卡以外的自己墓地最多2只恐龙族或岩石族的怪兽为对象才能发动（相同种族最多1只）。那些怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，创建两个效果，分别对应①②效果
function s.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合，以这张卡以外的自己墓地最多2只恐龙族或岩石族的怪兽为对象才能发动（相同种族最多1只）。那些怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 创建一个全局持续效果，用于监听破坏事件并触发自定义事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		-- 将全局持续效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断是否为己方或双方的破坏事件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 设置效果目标，检查是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，提示将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤动作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选被破坏的怪兽是否满足条件
function s.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not c:IsPreviousLocation(LOCATION_SZONE)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 判断破坏事件是否满足触发条件
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(s.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(s.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，传递破坏信息
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end
-- 判断是否满足②效果发动条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or rp==1-tp) and c:IsPreviousControler(tp)
end
-- 筛选墓地符合条件的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR+RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 筛选满足召唤数量和种族限制的怪兽组
function s.fselect(g,ft)
	return g:GetCount()<=ft and g:GetClassCount(Card.GetRace)==g:GetCount()
end
-- 设置②效果的目标和操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.spfilter(chkc,e,tp) end
	-- 获取己方场上可用的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c,e,tp)
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=g:SelectSubGroup(tp,s.fselect,false,1,2,ft)
	-- 设置当前连锁的目标卡片
	Duel.SetTargetCard(tg)
	-- 设置操作信息，提示将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 筛选可特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行②效果的特殊召唤操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁的目标卡片并筛选满足条件的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.spfilter2,nil,e,tp)
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #g>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #g>ft then
		-- 提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 执行特殊召唤动作
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
