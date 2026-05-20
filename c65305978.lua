--炎王の聖域
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「炎王的孤岛」在自己的场地区域表侧表示放置。
-- ②：1回合1次，自己的场地区域的卡被效果破坏的场合，可以作为代替把自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
-- ③：1回合1次，对方把怪兽特殊召唤的场合才能发动。只用自己场上的「炎王」怪兽为素材进行1只炎属性超量怪兽的超量召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动时的效果、代替破坏的永续效果以及对方特召时进行超量召唤的诱发效果。
function s.initial_effect(c)
	-- 将「炎王的孤岛」（卡号57554544）加入此卡的关联卡片密码列表中。
	aux.AddCodeList(c,57554544)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1张「炎王的孤岛」在自己的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的场地区域的卡被效果破坏的场合，可以作为代替把自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把怪兽特殊召唤的场合才能发动。只用自己场上的「炎王」怪兽为素材进行1只炎属性超量怪兽的超量召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中名为「炎王的孤岛」且未被禁止、且在场上唯一的卡片。
function s.stfilter(c,tp)
	return c:IsCode(57554544) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 卡片发动时的效果处理：询问玩家是否从卡组将1张「炎王的孤岛」在自己的场地区域表侧表示放置，若选择是，则送墓原场地区域的卡并放置新卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中满足条件的「炎王的孤岛」卡片组。
	local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在可放置的「炎王的孤岛」，则询问玩家是否发动该效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否放置「炎王的孤岛」？"
		-- 提示玩家选择要放置到场上的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1张满足条件的「炎王的孤岛」。
		local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 获取自己场地区域（魔法陷阱区第5格）当前存在的卡片。
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				-- 因规则原因将原本存在的场地区域卡片送去墓地。
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使后续的放置处理与送墓处理不视为同时进行。
				Duel.BreakEffect()
			end
			-- 将选中的「炎王的孤岛」在自己的场地区域表侧表示放置。
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
-- 过滤自己场地区域因效果被破坏且非代替破坏的卡片。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_FZONE)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤自己手卡或场上表侧表示、可被效果破坏且未确定破坏的炎属性怪兽。
function s.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的目标过滤与确认：检查是否有场地区域卡片被效果破坏，以及自己手卡或场上是否有可代替破坏的炎属性怪兽。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 检查自己手卡或场上是否存在至少1只可用于代替破坏的炎属性怪兽。
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 询问玩家是否使用代替破坏的效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择1只自己手卡或场上表侧表示的炎属性怪兽作为代替破坏的对象。
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 确定代替破坏效果的适用对象，即自己场地区域被效果破坏的卡。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行处理：展示此卡发动，并将选中的代替卡片破坏。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示此卡，提示不入连锁的代替破坏效果适用。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的代替卡片以效果破坏和代替破坏的原因破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 诱发效果的发动条件：对方成功特殊召唤怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤自己场上表侧表示且非衍生物的「炎王」怪兽（作为超量素材）。
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x81) and not c:IsType(TYPE_TOKEN)
end
-- 过滤额外卡组中可以使用当前素材进行超量召唤的炎属性超量怪兽。
function s.xyzfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsXyzSummonable(mg)
end
-- 诱发效果的目标确认：检查是否存在可用的「炎王」素材以及可超量召唤的炎属性超量怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有可作为超量素材的「炎王」怪兽。
		local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在可以使用这些「炎王」怪兽作为素材进行超量召唤的炎属性超量怪兽。
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	-- 设置连锁中的操作信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 诱发效果的执行处理：获取场上的「炎王」怪兽和额外卡组的炎属性超量怪兽，让玩家选择1只超量怪兽并进行超量召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可作为超量素材的「炎王」怪兽。
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中可以使用这些素材进行超量召唤的炎属性超量怪兽。
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 让玩家使用场上的「炎王」怪兽作为素材，对选中的炎属性超量怪兽进行超量召唤。
		Duel.XyzSummon(tp,xyz,g,1,6)
	end
end
