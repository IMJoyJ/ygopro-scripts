--予幻使 メディウス
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：场上有「予幻」卡存在的场合才能发动。这张卡从手牌特殊召唤。那个副：可以从卡组把1张「予幻」魔法·陷阱卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的表侧表示怪兽因效果被除外的场合才能发动。从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tscon)
	e2:SetTarget(s.tstg)
	e2:SetOperation(s.tsop)
	c:RegisterEffect(e2)
end
-- 发动条件过滤：场上表侧表示的「予幻」卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ce)
end
-- 特殊召唤效果发动条件检查
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在表侧表示的「予幻」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤效果发动准备与目标确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：怪兽区域有空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 检索过滤条件：「予幻」魔法·陷阱卡
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x1e0) and c:IsAbleToHand()
end
-- 特殊召唤效果处理：特殊召唤自身并可从卡组检索「予幻」魔法·陷阱卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否仍与连锁关联且特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 判断卡组是否存在可以加入手牌的「予幻」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否发动后续检索效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的「予幻」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 中断效果处理
		Duel.BreakEffect()
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 触发条件过滤：场上表侧表示怪兽被除外
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
end
-- 诱发效果发动条件检查
function s.tscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
-- 检索过滤条件：「予幻」卡
function s.thfilter2(c)
	return c:IsSetCard(0x1e6) and c:IsAbleToHand()
end
-- 特殊召唤过滤条件：从额外卡组特殊召唤的「予幻」怪兽
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x1e7)
		-- 判断是否可以从额外卡组特殊召唤到合适位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 二选一效果发动准备与目标确认
function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查选项1条件：卡组存在可检索的「予幻」卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	local b2=c:IsAbleToRemove()
		-- 检查选项2条件：自身可除外且额外卡组存在可特召的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动的效果分支
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},
			{b2,aux.Stringid(id,4),2})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置连锁操作信息：从卡组检索1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
		-- 设置连锁操作信息：除外自身
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
		-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 根据选择的分支执行效果处理
function s.tsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的「予幻」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		local c=e:GetHandler()
		-- 判断自身是否仍与连锁关联且成功表侧表示除外
		if not c:IsRelateToChain() or Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1张「予幻」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		local tc=g:GetFirst()
		if not tc then return end
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
