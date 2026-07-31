--蜃欺龍
-- 效果：
-- 种族·属性相同而等级不同的怪兽×2
-- 对方不能把自己场上的融合怪兽作为效果的对象。
-- 这张卡作为融合召唤的素材被送去墓地的场合：可以从额外卡组把1只融合怪兽效果无效守备表示特殊召唤，这个效果特殊召唤的怪兽在结束阶段回到额外卡组，这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。「妖灵龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制并设置融合召唤条件，注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足s.ffilter条件的2个怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 创建一个永续效果，使对方不能将自己场上的融合怪兽作为效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efftg)
	-- 设置该效果的过滤函数为aux.tgoval，用于判断是否能成为对方效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，当此卡作为融合素材被送去墓地时发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义匹配属性和种族的过滤函数，用于判断怪兽是否满足融合条件
function s.matchfilter(c,attr,race)
	return c:IsFusionAttribute(attr) and c:IsRace(race)
end
-- 定义融合召唤的过滤函数，确保融合素材满足属性、种族和等级要求
function s.ffilter(c,fc,sub,mg,sg)
	-- 判断当前融合素材组是否为空或无符合条件的卡
	return (not sg or sg:FilterCount(aux.TRUE,c)==0
			or (sg:IsExists(s.matchfilter,#sg-1,c,c:GetFusionAttribute(),c:GetRace())
				and not sg:IsExists(Card.IsLevel,1,c,c:GetLevel())))
		and c:IsLevelAbove(1)
end
-- 定义效果目标过滤函数，使只有融合怪兽才能成为效果对象
function s.efftg(e,c)
	return c:IsType(TYPE_FUSION)
end
-- 判断此卡是否在墓地且因融合被送去墓地，且不是因为返回效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 定义特殊召唤的过滤函数，确保额外卡组中的融合怪兽可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查是否有足够的位置进行特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤的效果目标，检测是否存在满足条件的融合怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否在额外卡组中存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤效果的操作函数，包括选择、特殊召唤和后续处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择一张满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local fid=e:GetHandler():GetFieldID()
	-- 判断是否成功特殊召唤了融合怪兽并进行后续处理
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 为特殊召唤的怪兽添加无效化效果，使其无法发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		tc:RegisterEffect(e1)
		-- 为特殊召唤的怪兽添加无效化效果，使其在结束阶段失去效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 创建一个持续效果，在结束阶段将特殊召唤的怪兽送回额外卡组
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.tdcon)
		e3:SetOperation(s.tdop)
		-- 注册结束阶段的处理效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 创建一个限制效果，使自己不能从额外卡组特殊召唤非融合怪兽
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果
	Duel.RegisterEffect(e4,tp)
end
-- 定义限制特殊召唤的过滤函数，禁止非融合怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断是否为正确的特殊召唤处理阶段
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将怪兽送回额外卡组的操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 显示提示动画，表示此卡发动了效果
	Duel.Hint(HINT_CARD,0,id)
	-- 将指定怪兽送回额外卡组并洗牌
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
