--黒の魔法神官
-- 效果：
-- 这张卡不能通常召唤。把自己场上2只6星以上的魔法师族怪兽解放的场合才能特殊召唤。
-- ①：陷阱卡发动时才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
function c88619463.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不能通过常规效果特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上2只6星以上的魔法师族怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c88619463.spcon)
	e2:SetTarget(c88619463.sptg)
	e2:SetOperation(c88619463.spop)
	c:RegisterEffect(e2)
	-- ①：陷阱卡发动时才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88619463,0))  --"陷阱发动无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c88619463.discon)
	e3:SetTarget(c88619463.distg)
	e3:SetOperation(c88619463.disop)
	c:RegisterEffect(e3)
end
-- 过滤解放所需的怪兽：等级6星以上的魔法师族怪兽
function c88619463.rfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(6) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件：检查场上是否存在可解放的满足条件的怪兽，且解放后有足够的怪兽区域
function c88619463.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可用于特殊召唤解放的、满足条件的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c88619463.rfilter,nil,tp)
	-- 检查是否能选出2只怪兽，在解放它们后主怪兽区有空位且能完成特殊召唤
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的目标：玩家选择2只满足条件的怪兽解放，并暂存所选怪兽组
function c88619463.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的满足条件的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c88619463.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择2只解放后能腾出足够怪兽区域的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作：解放选定的怪兽
function c88619463.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽组
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①的发动条件：此卡未被战斗破坏，且连锁中发动了陷阱卡，且该发动可以被无效
function c88619463.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查发动的效果是否为陷阱卡的发动，且该发动可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 效果①的效果目标：设置无效发动与破坏的操作信息
function c88619463.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：使该陷阱卡的发动无效并破坏
function c88619463.disop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 如果成功使该陷阱卡的发动无效，且该卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
