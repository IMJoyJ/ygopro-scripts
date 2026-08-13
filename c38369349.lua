--トゥーン・ドラゴン・エッガー
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在，把自己场上2只怪兽解放的场合可以特殊召唤。
-- ①：这张卡在特殊召唤的回合不能攻击。
-- ②：这张卡的攻击宣言之际，自己必须支付500基本分。
-- ③：对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。存在的场合，必须把卡通怪兽作为攻击对象。
-- ④：场上的「卡通世界」被破坏时这张卡破坏。
function c38369349.initial_effect(c)
	-- 将这张卡记载的卡名「卡通世界」（15259703）加入代码列表，用于关联/识别「卡通世界」。
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「卡通世界」存在，把自己场上2只怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c38369349.spcon)
	e2:SetTarget(c38369349.sptg)
	e2:SetOperation(c38369349.spop)
	c:RegisterEffect(e2)
	-- ④：场上的「卡通世界」被破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c38369349.sdescon)
	e3:SetOperation(c38369349.sdesop)
	c:RegisterEffect(e3)
	-- ③：对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c38369349.dircon)
	c:RegisterEffect(e4)
	-- ③：存在的场合，必须把卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c38369349.atcon)
	e5:SetValue(c38369349.atlimit)
	c:RegisterEffect(e5)
	-- ③：存在的场合，必须把卡通怪兽作为攻击对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c38369349.atcon)
	c:RegisterEffect(e6)
	-- ①：这张卡在特殊召唤的回合不能攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c38369349.atklimit)
	c:RegisterEffect(e7)
	-- ②：这张卡的攻击宣言之际，自己必须支付500基本分。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_COST)
	e8:SetCost(c38369349.atcost)
	e8:SetOperation(c38369349.atop)
	c:RegisterEffect(e8)
end
-- 过滤条件：场上表侧表示且卡号为15259703的「卡通世界」。
function c38369349.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 特殊召唤规则效果的条件：自己场上有表侧「卡通世界」存在，且自己的可解放怪兽中存在2只可在解放后空出足够区域并完成特殊召唤的怪兽。
function c38369349.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家可用于解放（非上级召唤）的怪兽组，作为特殊召唤解放的候选集合。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查自己场上（前场+后场）是否存在表侧表示的「卡通世界」。
	return Duel.IsExistingMatchingCard(c38369349.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 进一步检查候选解放组中能否选出2只怪兽，且解放它们后主怪兽区仍有空位满足此次特殊召唤。
		and rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的目标选择：从可解放怪兽中选择2只作为解放代价，保存选择结果并返回成功。
function c38369349.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可用于解放的怪兽组，作为特殊召唤解放的候选集合。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家显示选择解放卡片的提示信息：“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 在候选解放组中，按条件选出2只怪兽；aux.mzctcheckrel 确保解放后仍有主怪兽区空位且怪兽可释放。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前保存的2只解放对象，完成解放动作。
function c38369349.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因此解放选中的2只怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤离场事件中的卡：必须是因破坏离场、曾表侧表示、在场上的「卡通世界」。
function c38369349.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 当离场事件中存在满足上述条件的「卡通世界」时，触发④的自毁条件。
function c38369349.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38369349.sfilter,1,nil)
end
-- 处理④：将这张卡通蛋龙破坏。
function c38369349.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果为原因将这张卡通蛋龙破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤条件：表侧表示的卡通怪兽。
function c38369349.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击条件：对方场上不存在表侧表示卡通怪兽时允许直接攻击。
function c38369349.dircon(e)
	-- 判断对方场上没有表侧表示卡通怪兽，返回真则本卡可以获得直接攻击能力。
	return not Duel.IsExistingMatchingCard(c38369349.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 攻击限制条件：对方场上存在表侧表示卡通怪兽时，迫使对方向卡通怪兽攻击/本卡不能直接攻击。
function c38369349.atcon(e)
	-- 判断对方场上是否存在表侧表示卡通怪兽。
	return Duel.IsExistingMatchingCard(c38369349.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 作为EFFECT_CANNOT_SELECT_BATTLE_TARGET的判定：对方不能选择不是卡通怪兽或里侧表示的怪兽为攻击对象，从而只能选择表侧卡通怪兽攻击。
function c38369349.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 特殊召唤成功时，给本卡临时附加不能攻击的效果，持续到回合结束。
function c38369349.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 攻击宣言代价的判定：检查自己是否可以支付500基本分。
function c38369349.atcost(e,c,tp)
	-- 检查玩家是否拥有500LP可支付。
	return Duel.CheckLPCost(tp,500)
end
-- 攻击宣言代价的支付处理：实际从自己LP中支付500。
function c38369349.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 支付500基本分。
	Duel.PayLPCost(tp,500)
end
