--セイバー・リフレクト
-- 效果：
-- 「剑之反射」在1回合只能发动1张。
-- ①：自己场上有「X-剑士」怪兽存在，自己因战斗·效果受到伤害时才能发动。自己基本分回复受到的伤害的数值，给与对方那个数值的伤害。那之后，可以从卡组把1张「剑士」魔法·陷阱卡或者1张「加特姆士」卡加入手卡。
function c35037880.initial_effect(c)
	-- 对应效果原文：「剑之反射」在1回合只能发动1张；①：自己场上有「X-剑士」怪兽存在，自己因战斗·效果受到伤害时才能发动。自己基本分回复受到的伤害的数值，给与对方那个数值的伤害。那之后，可以从卡组把1张「剑士」魔法·陷阱卡或者1张「加特姆士」卡加入手卡。
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
-- 过滤条件：怪兽为表侧表示且属于「X-剑士」系列（0x100d）。
function c35037880.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 发动条件判定：自己受到伤害，并且自己场上有表侧表示的「X-剑士」怪兽存在。
function c35037880.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件：受伤的是自己（ep==tp），且自己场上存在至少1只表侧表示的「X-剑士」怪兽。
	return ep==tp and Duel.IsExistingMatchingCard(c35037880.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标处理：不需要选择对象；设置后续要执行的回复和伤害操作信息。
function c35037880.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将回复LP的操作标记为回复效果，对象为自己，回复数值为受到的伤害值。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
	-- 设置操作信息：将对对方造成伤害的操作标记为伤害效果，对象为对方，伤害数值为受到的伤害值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 检索对象条件：卡名含有「剑士」的魔法·陷阱卡（0xd）或者「加特姆士」卡（0xb0），并且该卡能够加入手卡。
function c35037880.filter(c)
	return ((c:IsSetCard(0xd) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0xb0)) and c:IsAbleToHand()
end
-- 效果处理：先回复自己LP并给与对方等量伤害，然后可选检索一张符合条件的卡加入手卡。
function c35037880.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因回复自己等于所受伤害的LP（作为连续处理的一步，不立即触发时点）。
	Duel.Recover(tp,ev,REASON_EFFECT,true)
	-- 以效果原因给与对方等于所受伤害的伤害（作为连续处理的一步，不立即触发时点）。
	Duel.Damage(1-tp,ev,REASON_EFFECT,true)
	-- 调用RDComplete完成伤害/回复的整个处理，触发对应的伤害/回复时点。
	Duel.RDComplete()
	-- 从自己卡组中获取所有满足filter过滤条件的卡，作为后续检索的候选组。
	local g=Duel.GetMatchingGroup(c35037880.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组存在符合条件的卡且玩家选择“是”（决定进行检索），则进入后续的加入手卡处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35037880,0)) then  --"卡组检索"
		-- 中断当前效果，使后续检索处理与前段的回复/伤害处理不在同一时点，避免错过时点。
		Duel.BreakEffect()
		-- 显示选择提示，让玩家从卡组中选择要加入手卡的卡（提示文字为“请选择要加入手牌的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡以效果原因加入其持有者的手卡（第二参数为nil表示送往持有者手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡，公开检索结果。
		Duel.ConfirmCards(1-tp,sg)
	end
end
