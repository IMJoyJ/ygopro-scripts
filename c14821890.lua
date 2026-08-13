--相剣暗転
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只幻龙族怪兽和对方场上2张卡为对象才能发动。那些卡破坏。
-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
function c14821890.initial_effect(c)
	-- ①：以自己场上1只幻龙族怪兽和对方场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,14821890)
	e1:SetTarget(c14821890.target)
	e1:SetOperation(c14821890.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14821890,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,14821891)
	e2:SetTarget(c14821890.sptg)
	e2:SetOperation(c14821890.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为表侧表示且种族为幻龙族（RACE_WYRM），用于筛选己方场上可作为①对象的幻龙族怪兽。
function c14821890.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM)
end
-- ①效果的发动条件判定：chkc 存在时直接返回 false（该效果需要分别选择两组对象，不通过单卡合法性检查）；在 chk==0 时确认己方场上有1只符合条件的幻龙族怪兽且对方场上有2张卡，才满足发动条件。
function c14821890.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己主要怪兽区是否存在至少1只符合条件的幻龙族怪兽（表侧表示且种族为幻龙族）。
	if chk==0 then return Duel.IsExistingTarget(c14821890.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上（主要怪兽区+魔法陷阱区）是否存在至少2张可被选择的卡（aux.TRUE 表示任意卡）。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 发送选择提示消息，告知玩家接下来要选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家在自己场上选择1只符合条件的幻龙族怪兽，并将其登记为本连锁的对象。
	local g1=Duel.SelectTarget(tp,c14821890.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次发送选择提示消息，提示玩家选择对方场上要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家在对方场上选择2张卡，并将它们登记为本连锁的对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置操作信息：将已选择的两组对象合并后，登记为本次连锁将要破坏的卡片及数量，供系统检测和后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- ①效果处理时的操作函数：从连锁信息中取出登记的对象，筛掉已经与效果失去联系的卡，然后将剩余对象全部以效果破坏。
function c14821890.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中登记的对象卡组（即发动①时选择的对象集合）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选出的对象卡片全部破坏，破坏原因为效果破坏（REASON_EFFECT）。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的发动条件判定函数：在 chk==0 时检查自己场上有空余怪兽区域、且玩家能够特殊召唤「相剑衍生物」，满足条件才可发动。
function c14821890.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域（至少1个空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤卡号为20001444的衍生物：幻龙族·水·4星·攻击力/守备力0（0x16b为其系列字段，TYPES_TOKEN_MONSTER表示衍生物怪兽）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置操作信息：本次处理会产生1只衍生物（CATEGORY_TOKEN），供系统检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理会进行1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理时的操作函数：再次确认仍有空位且仍有召唤权限后，创建「相剑衍生物」并以表侧表示特殊召唤；随后给该衍生物注册一个永续效果，限制自己在场时不能从额外卡组特殊召唤非同步怪兽。
function c14821890.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上还有可用的主要怪兽区域，避免效果处理时无法特招。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 处理时再次确认玩家仍满足特殊召唤该衍生物的条件（token参数和召唤权限）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 创建一只「相剑衍生物」（token，卡号14821891），所属玩家为 tp。
		local token=Duel.CreateToken(tp,14821891)
		-- 以表侧表示将衍生物特殊召唤到 tp 玩家的场上（使用特殊召唤流程的分步函数，需配合 Complete 使用）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c14821890.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 结束特殊召唤流程，正式完成本次特殊召唤，并触发特殊召唤成功的时点。
		Duel.SpecialSummonComplete()
	end
end
-- 自肃效果的判定函数：当要特殊召唤的卡位于额外卡组且不是同调怪兽时，禁止该特殊召唤（即限制只能从额外卡组特招同调怪兽）。
function c14821890.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
