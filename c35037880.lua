--セイバー・リフレクト
-- 效果：
-- 「剑之反射」在1回合只能发动1张。
-- ①：自己场上有「X-剑士」怪兽存在，自己因战斗·效果受到伤害时才能发动。自己基本分回复受到的伤害的数值，给与对方那个数值的伤害。那之后，可以从卡组把1张「剑士」魔法·陷阱卡或者1张「加特姆士」卡加入手卡。
function c35037880.initial_effect(c)
	-- 效果原文内容：「剑之反射」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,35037880+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c35037880.condition)
	e1:SetTarget(c35037880.target)
	e1:SetOperation(c35037880.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在「X-剑士」怪兽
function c35037880.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 效果作用：判断是否为己方受到战斗·效果伤害且场上有「X-剑士」怪兽
function c35037880.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己场上有「X-剑士」怪兽存在，自己因战斗·效果受到伤害时才能发动。
	return ep==tp and Duel.IsExistingMatchingCard(c35037880.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置连锁处理时的伤害与回复信息
function c35037880.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置己方回复伤害数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
	-- 效果作用：设置对方受到相同数值伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 效果作用：过滤「剑士」魔法·陷阱卡或「加特姆士」卡
function c35037880.filter(c)
	return ((c:IsSetCard(0xd) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0xb0)) and c:IsAbleToHand()
end
-- 效果作用：执行伤害与回复处理，并检索卡组
function c35037880.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：己方基本分回复受到的伤害数值
	Duel.Recover(tp,ev,REASON_EFFECT,true)
	-- 效果作用：对方受到相同数值伤害
	Duel.Damage(1-tp,ev,REASON_EFFECT,true)
	-- 效果作用：完成伤害/回复处理的时点触发
	Duel.RDComplete()
	-- 效果作用：检索满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(c35037880.filter,tp,LOCATION_DECK,0,nil)
	-- 效果作用：判断是否选择检索卡组卡片
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35037880,0)) then  --"卡组检索"
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 效果作用：确认对方手牌
		Duel.ConfirmCards(1-tp,sg)
	end
end
