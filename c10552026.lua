--剛鬼ジャドウ・オーガ
-- 效果：
-- 「刚鬼」怪兽2只
-- ①：1回合1次，这张卡所连接区的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，可以从自己墓地选「刚鬼 邪道食人魔」以外的1只「刚鬼」怪兽特殊召唤。
function c10552026.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，素材要求为2只「刚鬼」怪兽。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2,2)
	-- ①：1回合1次，这张卡所连接区的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，可以从自己墓地选「刚鬼 邪道食人魔」以外的1只「刚鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10552026,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c10552026.negcon)
	e1:SetTarget(c10552026.negtg)
	e1:SetOperation(c10552026.negop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：本卡未被战斗破坏确定，发动连锁的是怪兽效果，且发动位置在主要怪兽区并位于本卡的连接区域，且该连锁可以被无效。
function c10552026.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前连锁中触发效果的发动位置、区域编号和控制者。
	local loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	if p==1-tp then seq=seq+16 end
	-- 判断发动效果是否为怪兽效果、是否在主要怪兽区、发动位置所在序号是否在本卡的连接区域内，以及该连锁是否可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and bit.band(loc,LOCATION_MZONE)~=0 and bit.extract(c:GetLinkedZone(),seq)~=0 and Duel.IsChainNegatable(ev)
end
-- 效果发动时合法性检查与操作信息设定：发动时返回true；处理时声明无效对象为eg，并若对象卡可破坏则同时声明破坏操作。
function c10552026.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的发动效果对象（eg）标记为需要无效，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若对象卡可破坏，则将其标记为需要破坏，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 特殊召唤的过滤条件：选择自己墓地中的「刚鬼」怪兽，且卡名不是「刚鬼 邪道食人魔」自身，且能被效果特殊召唤。
function c10552026.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and not c:IsCode(10552026) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：无效那个发动并破坏对应卡片；成功后若场上有空位，则从自己墓地特殊召唤1只符合条件的「刚鬼」怪兽（需玩家选择是否发动）。
function c10552026.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 首先无效该连锁发动，然后确认发动效果的那张卡仍与效果相关（未离场）时将其破坏；只有无效和破坏均成功才继续。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 检查自己场上主要怪兽区是否有空位，若没有空位则不能进行后续特殊召唤，直接结束。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 从自己墓地选取满足特殊召唤条件且不受王家长眠之谷影响的「刚鬼」怪兽（不含本卡），作为可特殊召唤的候选组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10552026.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 如果候选组非空，且玩家选择“是”，则执行后续的特殊召唤（询问玩家是否要特殊召唤）。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(10552026,1)) then  --"是否选「刚鬼」怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤在不同时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 向玩家提示“请选择要特殊召唤的卡”，并将选择提示信息存入缓存。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不无视召唤条件和苏生限制）。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
