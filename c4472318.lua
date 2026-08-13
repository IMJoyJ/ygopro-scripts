--岩竜ベアロック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被对方破坏的场合，以这张卡以外的自己墓地最多2只恐龙族或岩石族的怪兽为对象才能发动（相同种族最多1只）。那些怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：创建并注册①效果（手卡特殊召唤）、②效果（被对方破坏时特殊召唤墓地怪兽）以及用于检测破坏事件的全局辅助效果。
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
		-- 这个卡名的①②的效果1回合各能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		-- 将全局破坏检测效果ge1注册到全场（玩家0），用于监听所有破坏事件，为①效果筛选‘自己的手卡·场上的怪兽被破坏’的触发条件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- ①效果的发动条件判定：自定义事件ev表示被破坏的怪兽归属方，当ev为自己或双方时，说明自己的手卡·场上的怪兽被破坏，满足条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- ①效果发动时检查：自己场上主要怪兽区有空位，且这张卡能被特殊召唤；满足则允许发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区域是否有空位，用于后续从手卡特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本连锁的操作信息，声明本效果将特殊召唤这张卡（数量1），供其他卡片（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果相关，则以表侧表示从手卡特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡特殊召唤到tp的场上，表示形式为表侧表示，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 全局破坏检测的过滤函数：判断被破坏的卡是否属于‘自己的手卡·场上的怪兽’，要求破坏原因为战斗/效果、破坏前位置在手卡或场上（非魔陷区）、原类型为怪兽且控制者为tp。
function s.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not c:IsPreviousLocation(LOCATION_SZONE)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 全局破坏检测ge1的触发条件：若本次破坏的卡中存在满足①条件的手卡·场上怪兽，则用label记录破坏归属（自己/对方/双方），供后续触发对应玩家的①效果。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(s.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(s.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局破坏检测的操作：将原破坏事件转换为自定义事件EVENT_CUSTOM+id，并把记录的归属玩家作为ev参数传递给①效果。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 发起自定义事件：将eg（被破坏的卡组）和归属玩家等信息作为事件参数，使手牌中的这张卡能触发①效果。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end
-- ②效果的发动条件判定：这张卡被对方破坏（战斗破坏或效果破坏的发动方为对方），且破坏前由自己控制。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or rp==1-tp) and c:IsPreviousControler(tp)
end
-- ②效果的对象筛选条件：候选卡为恐龙族或岩石族，能够被特殊召唤，并且能够成为本效果的对象。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR+RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 选择子组时的限制函数：所选卡数不超过可用怪兽区空格数，且不同种族数与卡数相等，保证相同种族最多选择1只。
function s.fselect(g,ft)
	return g:GetCount()<=ft and g:GetClassCount(Card.GetRace)==g:GetCount()
end
-- ②效果的发动目标处理：检查空格和可对象卡；在墓地中选出最多2只恐龙族/岩石族（相同种族最多1只）作为对象，并设置特殊召唤的操作信息，同时考虑青眼精灵龙的效果限制。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.spfilter(chkc,e,tp) end
	-- 获取自己场上主要怪兽区域的可用空格数，用于限制可选择和特殊召唤的怪兽数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 发动合法性检查：可用空格数大于0，且墓地存在至少1只满足条件的怪兽可以成为对象。
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 获取墓地中所有满足条件的恐龙族/岩石族怪兽（除外这张卡自身）作为备选集合。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c,e,tp)
	-- 显示选择提示消息，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=g:SelectSubGroup(tp,s.fselect,false,1,2,ft)
	-- 将选择出的卡组tg设置为当前连锁的效果对象（取对象效果）。
	Duel.SetTargetCard(tg)
	-- 设置效果处理信息：声明特殊召唤对象为tg，数量为tg的卡数，用于连锁后的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 效果处理时的二次筛选：对象卡必须仍与效果相关，且当前仍能被特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：从取对象中筛出仍可特殊召唤的卡；若可特召数量超过可用空格或受青眼精灵龙限制，则减少特召唤数量，最终将卡特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取自己场上可用怪兽区空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从当前连锁的对象卡组中筛选出仍满足特殊召唤条件的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.spfilter2,nil,e,tp)
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #g>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #g>ft then
		-- 当可特殊召唤的卡数超过可用空格数时，提示玩家选择要实际特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将最终选定的卡组g以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
