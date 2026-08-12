--蜃欺龍
-- 效果：
-- 相同种族·属性而等级不同的怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的融合怪兽作为效果的对象。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从额外卡组把1只融合怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到额外卡组。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果：设置特殊召唤限制与融合召唤手续（相同种族·属性而等级不同的怪兽×2），注册永续效果①（对方不能把自己场上的融合怪兽作为效果对象）和诱发效果②（成为融合召唤素材送去墓地时从额外卡组特殊召唤融合怪兽，1回合1次）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只满足s.ffilter条件的怪兽（相同种族·属性而等级不同）作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的融合怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efftg)
	-- 设定该保护效果的判定值：仅当效果的使用者是对方玩家时，自己场上的融合怪兽才不会成为其效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从额外卡组把1只融合怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到额外卡组。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
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
-- 过滤函数：检查卡的融合素材属性与种族是否与给定的属性·种族相同
function s.matchfilter(c,attr,race)
	return c:IsFusionAttribute(attr) and c:IsRace(race)
end
-- 融合素材过滤函数：要求素材为等级1以上，且已选素材组中不存在与该卡种族·属性相同或等级相同的怪兽，即保证素材为相同种族·属性而等级不同的怪兽
function s.ffilter(c,fc,sub,mg,sg)
	-- 若尚未选择素材或已选素材组中没有与该卡不同的卡（首个素材），则直接通过过滤
	return (not sg or sg:FilterCount(aux.TRUE,c)==0
			or (sg:IsExists(s.matchfilter,#sg-1,c,c:GetFusionAttribute(),c:GetRace())
				and not sg:IsExists(Card.IsLevel,1,c,c:GetLevel())))
		and c:IsLevelAbove(1)
end
-- 保护对象过滤函数：只选择自己场上的融合怪兽
function s.efftg(e,c)
	return c:IsType(TYPE_FUSION)
end
-- 发动条件：这张卡在墓地存在，且是因融合召唤被作为素材送去墓地（不是因为回到墓地等原因）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 特殊召唤候选过滤函数：额外卡组中可以守备表示特殊召唤的融合怪兽，且场上有可供额外卡组怪兽出场的空格
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查自己场上是否存在能让该额外卡组怪兽出场的空余怪兽区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果目标设定：确认额外卡组存在可特殊召唤的融合怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己的额外卡组中至少存在1只满足特殊召唤条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁将处理从额外卡组把1只卡特殊召唤的操作（对象在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：让玩家从额外卡组选择1只融合怪兽守备表示特殊召唤，将其效果无效化并登记结束阶段回到额外卡组的处理，最后适用本回合自己只能从额外卡组特殊召唤融合怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local fid=e:GetHandler():GetFieldID()
	-- 若选中了卡，则以守备表示将其特殊召唤（分步特殊召唤，成功后继续后续处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段回到额外卡组。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.tdcon)
		e3:SetOperation(s.tdop)
		-- 把结束阶段时将那只怪兽送回额外卡组的持续效果注册为玩家效果，使其在全局环境中生效
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成本次分步特殊召唤，进行特殊召唤成功时点的结算
	Duel.SpecialSummonComplete()
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 把特殊召唤限制效果注册为玩家效果：这个回合自己不是融合怪兽不能从额外卡组特殊召唤
	Duel.RegisterEffect(e4,tp)
end
-- 特殊召唤限制过滤函数：位于额外卡组的非融合怪兽不能被特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 结束阶段处理的发动条件：检查被标记的怪兽仍是本次效果特殊召唤的那只（标记ID一致），否则重置该效果
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段处理：显示卡片动画后，把这个效果特殊召唤的怪兽以效果处理回到持有者的额外卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 显示「蜃欺龙」的卡片动画，提示正在处理该卡的效果
	Duel.Hint(HINT_CARD,0,id)
	-- 以效果处理把该怪兽送回额外卡组（返回最顶端并标记需要洗切）
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
