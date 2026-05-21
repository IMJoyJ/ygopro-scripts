--天獄の王
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。手卡的这张卡直到对方回合结束时公开。这个效果公开期间，场上的里侧表示卡不会被效果破坏。
-- ②：盖放的魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。以在手卡被公开中的状态把这个效果发动的场合，可以再从卡组把1张魔法·陷阱卡在自己场上盖放。那张卡在下个回合的结束阶段除外。
local s,id,o=GetID()
-- 注册卡片的效果①（手牌公开及里侧卡不被破坏）和效果②（盖放魔陷发动时手牌特召及卡组盖放魔陷）。
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。手卡的这张卡直到对方回合结束时公开。这个效果公开期间，场上的里侧表示卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：盖放的魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。以在手卡被公开中的状态把这个效果发动的场合，可以再从卡组把1张魔法·陷阱卡在自己场上盖放。那张卡在下个回合的结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的处理：将手牌的这张卡公开直到对方回合结束，并在此期间适用场上的里侧表示卡不会被效果破坏的永续效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local fid=c:GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,EFFECT_FLAG_CLIENT_HINT,1,fid,66)
	-- 手卡的这张卡直到对方回合结束时公开。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	c:RegisterEffect(e1)
	-- 这个效果公开期间，场上的里侧表示卡不会被效果破坏。盖放的魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。以在手卡被公开中的状态把这个效果发动的场合，可以再从卡组把1张魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetLabel(fid)
	e2:SetLabelObject(c)
	e2:SetCondition(s.indcon)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 注册场上里侧表示卡不会被效果破坏的全局效果。
	Duel.RegisterEffect(e2,tp)
end
-- 检查天狱之王是否在手牌中维持公开状态，以确定不被破坏效果是否适用。
function s.indcon(e)
	local c=e:GetLabelObject()
	return c:GetFlagEffectLabel(id)==e:GetLabel()
end
-- 过滤不被效果破坏的对象，仅适用于场上的里侧表示卡。
function s.indtg(e,c)
	return c:IsFacedown()
end
-- 效果②的发动条件：盖放的魔法·陷阱卡发动时（排除从手牌发动的情况）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and not re:GetHandler():IsStatus(STATUS_ACT_FROM_HAND)
end
-- 效果②的靶向处理：检查自身能否特殊召唤，并根据手牌是否公开决定是否追加从卡组盖放魔陷的效果分类。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：包含特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	if c:IsPublic() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetLabel(0)
	end
end
-- 过滤卡组中可以盖放的魔法·陷阱卡。
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的效果处理：特殊召唤自身，若发动时处于公开状态，则可以再从卡组盖放1张魔陷，并注册该卡在下个回合结束阶段除外的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡从手牌特殊召唤，并判断是否特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取卡组中所有满足盖放条件的魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
		-- 若是以公开状态发动，且卡组有可盖放的卡，则由玩家选择是否进行盖放。
		if e:GetLabel()==1 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组把1张魔法·陷阱卡盖放？"
			-- 中断当前效果处理，使后续的盖放处理与特殊召唤不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡在自己场上盖放。
			Duel.SSet(tp,sg)
			local tc=sg:GetFirst()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_REDIRECT,0,1)
			-- 那张卡在下个回合的结束阶段除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			-- 将除外效果的触发回合数设置为当前回合的下一回合。
			e1:SetLabel(Duel.GetTurnCount()+1)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			e1:SetCondition(s.rmcon)
			e1:SetOperation(s.rmop)
			-- 注册在下个回合结束阶段将盖放卡除外的全局时点效果。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 检查是否到了下个回合的结束阶段，且该盖放卡依然带有标记。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 判断当前回合数是否等于设定的除外回合数（即下个回合）。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 执行除外操作，将目标卡片表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动除外效果的卡片（天狱之王）。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 因效果将目标卡片表侧表示除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
