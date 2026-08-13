--SRウィング・シンクロン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，可以发动。自己的灵摆区域1张风属性·2星的灵摆怪兽卡和这张卡破坏，从额外卡组把1只「幻透翼同调龙」当作同调召唤作特殊召唤。这个回合，自己的灵摆区域的卡不会被效果破坏，自己不是风属性怪兽不能特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡表侧加入额外卡组的场合，若自己场上的风属性同调怪兽的种族是2种类以上则能发动。从卡组把1张「疾行机人」魔法·陷阱卡送去墓地。
local s,id,o=GetID()
-- 注册本卡的灵摆效果与怪兽效果：灵摆效果为1回合1次破坏自己灵摆区1张风属性·2星灵摆怪兽和自身，从额外卡组将「幻透翼同调龙」当作同调召唤特殊召唤，并适用灵摆区保护与风属性自肃；怪兽效果为表侧加入额外卡组的场合，若自己场上的风属性同调怪兽种族为2种类以上，从卡组将1张「疾行机人」魔法·陷阱卡送入墓地；同时添加灵摆属性和记载「幻透翼同调龙」卡名。
function s.initial_effect(c)
	-- 记载这张卡上记载着卡号82044279「幻透翼同调龙」，用于相关规则的判定。
	aux.AddCodeList(c,82044279)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡在灵摆区域发动，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 对应原灵摆效果：①：1回合1次，可以发动。自己的灵摆区域1张风属性·2星的灵摆怪兽卡和这张卡破坏，从额外卡组把1只「幻透翼同调龙」当作同调召唤作特殊召唤。这个回合，自己的灵摆区域的卡不会被效果破坏，自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 对应原怪兽效果：这个卡名的怪兽效果1回合只能使用1次。①：这张卡表侧加入额外卡组的场合，若自己场上的风属性同调怪兽的种族是2种类以上则能发动。从卡组把1张「疾行机人」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤筛选函数：选择额外卡组中卡号为82044279的「幻透翼同调龙」，且为同调怪兽、能够以同调召唤方式特殊召唤，并需要额外卡组怪兽的出场空格。
function s.spfilter(c,e,tp)
	return c:IsCode(82044279) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 额外检查：从额外卡组特殊召唤时，玩家场上是否存在可用怪兽区域（考虑到要召唤的这张卡自身）。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义破坏对象筛选函数：选择灵摆怪兽，且原始属性为风、原始等级为2，对应“风属性·2星的灵摆怪兽卡”。
function s.desfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:GetOriginalAttribute()==ATTRIBUTE_WIND
		and c:GetOriginalLevel()==2
end
-- 灵摆效果发动条件判定：自己灵摆区存在符合条件的风属性2星灵摆怪兽、没有“必须作为同调素材”的限制、且额外卡组存在可特殊召唤的「幻透翼同调龙」，并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区是否存在1张满足破坏条件的风属性2星灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		-- 检查双方是否有“必须作为同调素材”的效果影响，因为后续将进行当作同调召唤的特殊召唤。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在满足特殊召唤条件的「幻透翼同调龙」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 取得自己灵摆区域当前的全部卡，作为可能被破坏的对象组。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置操作信息：本效果将破坏自己灵摆区的2张卡，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息：本效果将从额外卡组特殊召唤1只怪兽，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果处理：破坏自己和另一张符合条件的灵摆怪兽；若成功，从额外卡组选择1只「幻透翼同调龙」以同调召唤方式特殊召唤；之后适用本回合灵摆区不会被效果破坏、自己不能特殊召唤风属性以外怪兽的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认发动的这张卡仍在灵摆区且与效果相关，且场上仍存在符合条件的另一张破坏对象。
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler()) then
		-- 再次取得自己灵摆区全部卡，作为实际破坏的对象。
		local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		-- 只有灵摆区至少有2张卡、实际破坏数量为2、且没有影响同调素材的限制时，才继续执行特殊召唤。
		if dg:GetCount()>=2 and Duel.Destroy(dg,REASON_EFFECT)==2 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then
			-- 弹出选择提示，让玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1张满足筛选条件的「幻透翼同调龙」。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
			if tc then
				tc:SetMaterial(nil)
				-- 以同调召唤方式将选择的怪兽特殊召唤到场上，若成功则继续；这里不检查召唤条件并保留苏生限制的判定。
				if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
	-- 对应效果原文：“这个回合，自己的灵摆区域的卡不会被效果破坏，自己不是风属性怪兽不能特殊召唤。”（此处开始创建灵摆区保护与特殊召唤自肃效果）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将灵摆区不受效果破坏的永续效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 实现“这个回合，自己的灵摆区域的卡不会被效果破坏，自己不是风属性怪兽不能特殊召唤”中的自肃部分，并定义怪兽效果所需的辅助函数；对应原文为“这个回合……自己不是风属性怪兽不能特殊召唤。”和“①：这张卡表侧加入额外卡组的场合，若自己场上的风属性同调怪兽的种族是2种类以上则能发动。从卡组把1张「疾行机人」魔法·陷阱卡送去墓地。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤风属性以外怪兽”的自肃效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的判定函数：若尝试特殊召唤的怪兽不是风属性，则禁止该特殊召唤。
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤出自己场上表侧表示的风属性同调怪兽，用于判断种族种类数。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 怪兽效果的触发条件：这张卡以表侧表示存在于额外卡组（即表侧加入额外卡组时）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
-- 筛选卡组中卡名含有「疾行机人」字段的魔法·陷阱卡，且能够送入墓地。
function s.tgfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 怪兽效果发动条件判定：卡组存在符合条件的「疾行机人」魔法·陷阱卡，且自己场上的风属性同调怪兽的种族种类数为2种类以上；满足则设置操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若卡组中没有符合条件的可送墓卡片，则本效果不能发动。
		if not Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) then return false end
		-- 取得自己场上全部表侧表示的风属性同调怪兽，用于种族种类统计。
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		return g:GetClassCount(Card.GetRace)>=2
	end
	-- 设置操作信息：本效果将从卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果处理：从卡组选择1张「疾行机人」魔法·陷阱卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的「疾行机人」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地，原因记为效果。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
