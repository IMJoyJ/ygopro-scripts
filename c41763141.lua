--Fata Dragna
-- 效果：
-- 种族·属性相同而等级不同的怪兽×2
-- 对方不能把自己场上的融合怪兽作为效果的对象。
-- 这张卡作为融合召唤的素材被送去墓地的场合：可以从额外卡组把1只融合怪兽效果无效守备表示特殊召唤，这个效果特殊召唤的怪兽在结束阶段回到额外卡组，这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。「妖灵龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果主函数，注册融合召唤手续、场上融合怪兽的抗性效果，以及作为融合素材送墓时的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册融合召唤素材手续：需要2只满足特定条件的怪兽（种族·属性相同而等级不同）。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 对方不能把自己场上的融合怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efftg)
	-- 设置不能成为效果对象效果的Value为aux.tgoval，即不会成为对方卡片效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这张卡作为融合召唤的素材被送去墓地的场合：可以从额外卡组把1只融合怪兽效果无效守备表示特殊召唤，这个效果特殊召唤的怪兽在结束阶段回到额外卡组，这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。「妖灵龙」的这个效果1回合只能使用1次。
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
-- 过滤函数：检查怪兽是否与当前选定素材的融合属性和种族相同。
function s.matchfilter(c,attr,race)
	return c:IsFusionAttribute(attr) and c:IsRace(race)
end
-- 融合素材过滤函数：检查怪兽是否满足等级大于等于1，且素材组合中的怪兽必须种族·属性相同且等级不同。
function s.ffilter(c,fc,sub,mg,sg)
	-- 判断素材选择状态：如果已选的素材集合为空或者只选择了一只怪兽，则返回true。
	return (not sg or sg:FilterCount(aux.TRUE,c)==0
			or (sg:IsExists(s.matchfilter,#sg-1,c,c:GetFusionAttribute(),c:GetRace())
				and not sg:IsExists(Card.IsLevel,1,c,c:GetLevel())))
		and c:IsLevelAbove(1)
end
-- 对方不能作为对象效果的过滤函数：判断卡片是否为融合怪兽。
function s.efftg(e,c)
	return c:IsType(TYPE_FUSION)
end
-- 特殊召唤效果的触发条件：这张卡在墓地存在，且作为融合召唤的素材被送去墓地，并且不为墓地返回。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 额外卡组特殊召唤融合怪兽的过滤条件：是融合怪兽、能以表侧守备表示特殊召唤，且场上有额外卡组特召的位置。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查从额外卡组特殊召唤该卡时，是否有可用的额外怪兽区域或主要怪兽区域空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤效果的Target函数：检查额外卡组是否存在符合特召条件的卡，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的合法性检查：额外卡组是否存在至少1只可以特殊召唤的融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息：预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的Operation函数：从额外卡组选择1只融合怪兽效果无效表侧守备表示特殊召唤，并注册结束阶段返回额外卡组的效果，同时施加本回合不能特召融合怪兽以外的额外卡组怪兽的自誓限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组选择1只满足条件的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local fid=e:GetHandler():GetFieldID()
	-- 如果成功选择怪兽，则尝试将其以表侧守备表示在特殊召唤步骤中召唤。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		tc:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到额外卡组
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.tdcon)
		e3:SetOperation(s.tdop)
		-- 注册在回合结束阶段将特召怪兽送回额外卡组的延迟效果。
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成所有特殊召唤步骤的后续处理。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册自誓效果，直到回合结束限制非融合怪兽从额外卡组的特殊召唤。
	Duel.RegisterEffect(e4,tp)
end
-- 限制特殊召唤的过滤函数：如果不是融合怪兽，则无法从额外卡组特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 结束阶段卡片回到额外卡组的触发条件：特召卡片的标记和当前效果标记一致。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段卡片回到额外卡组的操作：发送卡片动画提示，并将其送回额外卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 发送妖灵龙的手动效果卡片展示动画。
	Duel.Hint(HINT_CARD,0,id)
	-- 通过效果将特殊召唤的融合怪兽送回额外卡组。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
