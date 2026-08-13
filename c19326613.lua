--妖精伝姫のはじまりはじまり
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地·除外状态各把最多1只光属性「妖精传姬」怪兽特殊召唤（同名卡最多1张）。这个回合，自己不是魔法师族怪兽不能特殊召唤。
-- ②：这张卡被除外的场合或者从场上以外送去墓地的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡在自己场上没有「妖精传姬」怪兽存在的场合不能发动。
local s,id,o=GetID()
-- 初始化效果：创建并注册①效果（发动时从手卡·墓地·除外区特殊召唤光属性「妖精传姬」怪兽，并附加本回合只能特殊召唤魔法师族的自肃）和②效果（该卡被除外或从场上以外送去墓地时可在自己场上盖放；将②的两种触发条件分别注册为e2和e3，共享1回合1次）。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地·除外状态各把最多1只光属性「妖精传姬」怪兽特殊召唤（同名卡最多1张）。这个回合，自己不是魔法师族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡在自己场上没有「妖精传姬」怪兽存在的场合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.setcon)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤候选的过滤条件：表侧表示、属于「妖精传姬」系列、光属性，且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1db) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：自己主怪兽区有空位，并且手卡·墓地·除外区中至少有1只符合条件的「妖精传姬」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地·除外区中是否存在至少1只满足s.spfilter的「妖精传姬」光属性怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，候选区域为手卡·墓地·除外区，数量在效果处理时确定（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 定义选择组的合法性：若只选1张则直接合法；若选多张，必须卡名互不相同，且手卡、墓地、除外区各最多只能选1张。
function s.gcheck(g)
	if #g==1 then return true end
	-- 检查所选怪兽的卡名均不相同。
	return aux.dncheck(g)
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<2
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<2
		and g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)<2
end
-- 效果处理：获取所有可特召的候选怪兽，计算可用主怪兽区空格；若存在可特召对象，选择1至3张（受空格数和青眼精灵龙限制）表侧特殊召唤；随后给己方附加本回合不能特殊召唤魔法师族以外怪兽的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡、墓地、除外区中所有满足s.spfilter且不受王家长眠之谷影响的「妖精传姬」光属性怪兽作为候选组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 计算自己主要怪兽区当前可用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and #g>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家从候选组中选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,math.min(3,ft))
		if sg then
			-- 将选择的怪兽全部以表侧表示特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 该段代码包含①效果结束后的自肃（本回合不能特殊召唤魔法师族以外怪兽）以及②效果的送墓触发条件、盖放处理。对应原文：这个回合，自己不是魔法师族怪兽不能特殊召唤。②：这张卡被除外的场合或者从场上以外送去墓地的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡在自己场上没有「妖精传姬」怪兽存在的场合不能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果以玩家为对象注册到场上，持续到结束阶段，使tp玩家本回合不能特殊召唤非魔法师族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制的判定：当被特殊召唤的怪兽不是魔法师族时，禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SPELLCASTER)
end
-- 定义②效果从场上以外送去墓地的触发条件：这张卡在被送去墓地前的所在区域不是场上。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果发动时的目标检查：确认这张卡可以盖放；若卡在墓地，则额外设置操作信息，表示它将要离开墓地。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息：该效果会使墓地的这张卡离开墓地并盖放到场上，以便与王家长眠之谷等效果互动。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- ②效果处理：若这张卡仍与当前连锁关联且不受王家长眠之谷影响，将其盖放到自己场上；盖放成功后，若自己场上没有表侧「妖精传姬」怪兽，则为该卡附加不能发动效果的限制。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与当前连锁相关、是否不受王家长眠之谷影响，并尝试将其盖放到自己场上；仅当成功盖放时才继续附加限制效果。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 为盖放后的这张卡附加限制效果，使其在自己场上没有表侧「妖精传姬」怪兽存在的场合不能发动效果。对应原文：这个效果盖放的这张卡在自己场上没有「妖精传姬」怪兽存在的场合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「妖精传姬开始啦开始啦」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.actcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 定义场上是否存在表侧「妖精传姬」怪兽的过滤条件。
function s.actfilter(c)
	return c:IsSetCard(0x1db) and c:IsFaceup()
end
-- 定义上述限制效果生效的条件：这张卡当前不具备效果有效状态（效果无效化），且自己场上不存在表侧「妖精传姬」怪兽。
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 判断自己场上不存在表侧「妖精传姬」怪兽，是限制效果的补充条件。
		and not Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
