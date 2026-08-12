--マズルフラッシュ・ドラゴン
--not fully implemented
-- 效果：
-- 龙族怪兽2只以上
-- 自己不能在这张卡所连接区让怪兽出现。
-- ①：1回合1次，这张卡所连接区有怪兽召唤·特殊召唤的场合才能发动。选这张卡所连接区1只怪兽破坏，给与对方500伤害。
-- ②：这张卡为对象的魔法·陷阱·怪兽的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效。
function c95372220.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要2只以上的龙族怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DRAGON),2)
	-- 自己不能在这张卡所连接区让怪兽出现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c95372220.zonelimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，这张卡所连接区有怪兽召唤·特殊召唤的场合才能发动。选这张卡所连接区1只怪兽破坏，给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95372220,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(c95372220.descon)
	e3:SetTarget(c95372220.destg)
	e3:SetOperation(c95372220.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：这张卡为对象的魔法·陷阱·怪兽的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(95372220,1))
	e5:SetCategory(CATEGORY_NEGATE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCondition(c95372220.negcon)
	e5:SetCost(c95372220.negcost)
	e5:SetTarget(c95372220.negtg)
	e5:SetOperation(c95372220.negop)
	c:RegisterEffect(e5)
end
-- 限制自己不能使用的怪兽区域（返回这张卡所连接的区域，使其不能被自己使用）。
function c95372220.zonelimit(e)
	return 0x7f007f & ~e:GetHandler():GetLinkedZone()
end
-- 过滤在连接端召唤、特殊召唤的怪兽（包括在场上或离场前处于连接端的情况）。
function c95372220.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.band(ec:GetLinkedZone(c:GetPreviousControler()),bit.lshift(0x1,c:GetPreviousSequence()))~=0
	end
end
-- 破坏效果的发动条件：检查是否有怪兽召唤·特殊召唤到这张卡的连接区。
function c95372220.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95372220.cfilter,1,nil,e:GetHandler())
end
-- 破坏效果的发动检测：检查连接区是否有可破坏的怪兽，并设置破坏与伤害的操作信息。
function c95372220.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetLinkedGroup()
	if chk==0 then return g:GetCount()>0 end
	-- 设置破坏操作信息，预计从连接区破坏1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害操作信息，预计给与对方500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 破坏效果的处理：让玩家从连接区选择1只怪兽破坏，并给与对方500点伤害。
function c95372220.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup()
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local tg=g:Select(tp,1,1,nil)
	if tg:GetCount()>0 then
		-- 显式显示被选择的卡片。
		Duel.HintSelection(tg)
		-- 尝试以效果破坏选中的怪兽，若成功破坏则执行后续伤害处理。
		if Duel.Destroy(tg,REASON_EFFECT)>0 then
			-- 给与对方500点效果伤害。
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
-- 无效效果的发动条件：检查当前连锁的效果是否以这张卡为对象，且该效果的发动可以被无效。
function c95372220.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的对象卡片组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回对象卡片组中是否包含这张卡，且该发动是否可以被无效。
	return tg and tg:IsContains(c) and Duel.IsChainNegatable(ev)
end
-- 过滤可作为解放Cost的怪兽（排除在战斗中已被破坏的怪兽）。
function c95372220.costfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 无效效果的消耗：检查并选择自己场上1只怪兽解放。
function c95372220.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己场上是否存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c95372220.costfilter,1,nil) end
	-- 让玩家选择自己场上1只怪兽。
	local g=Duel.SelectReleaseGroup(tp,c95372220.costfilter,1,1,nil)
	-- 解放选中的怪兽作为发动的代价。
	Duel.Release(g,REASON_COST)
end
-- 无效效果的发动检测：设置无效发动的操作信息。
function c95372220.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效操作信息，预计无效该连锁的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效效果的处理：使该连锁的发动无效。
function c95372220.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前连锁的发动。
	Duel.NegateActivation(ev)
end
