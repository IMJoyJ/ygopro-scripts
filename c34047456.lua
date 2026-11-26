--ギガンティック・サンダークロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己和对方的除外状态的卡数量差的数量的双方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。那之后，对方可以从自身卡组把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册速攻魔法发动效果（1回合1张誓约限制），以双方除外状态卡数量差的数量的双方的场上·墓地怪兽为对象将其除外，之后对方可选从卡组特召1只怪兽
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。 ①：以自己和对方的除外状态的卡数量差的数量的双方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。那之后，对方可以从自身卡组把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：检查卡片是否为怪兽卡且可以被除外
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 发动检测、取对象及连锁信息设置：计算双方除外区卡数差值，确认双方场上·墓地有足够数量的怪兽并选择该数量作为对象，同时登记除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x14) and s.filter(chkc) end
	-- 计算己方与对方除外状态的卡片数量之差的绝对值
	local ct=math.abs(Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_REMOVED))
	-- 发动条件检查：确认双方除外卡数量差大于0，且双方怪兽区·墓地合计存在不少于该差值数量的满足条件怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.filter,tp,0x14,0x14,ct,nil) end
	-- 向己方提示选择要除外的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让己方从双方的怪兽区·墓地中准确选择等于数量差的怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0x14,0x14,ct,ct,nil)
	-- 登记连锁的除外操作信息，预计将所选的对象怪兽全部除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- 筛选条件：检查对方卡组中的卡能否被对方特殊召唤
function s.sfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：将仍与连锁有联系的对象怪兽表侧除外；若成功除外且对方怪兽区有空位，则询问对方是否从其卡组选1只怪兽特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的所有对象怪兽并筛选出仍与效果有联系的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果将对象怪兽表侧除外，若1只也未能除外或对方主要怪兽区没有空位则结束处理
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
	-- 获取对方卡组中可被对方特殊召唤的全部怪兽组
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_DECK,nil,e,1-tp)
	-- 若对方卡组存在可特召的怪兽，询问对方是否从自身卡组特殊召唤1只怪兽
	if #sg>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否从卡组特殊召唤？"
		-- 向玩家提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		-- 中断效果处理，使对方的特殊召唤与前面的除外处理视为不同时处理
		Duel.BreakEffect()
		-- 由对方将所选怪兽以表侧表示特殊召唤到对方场上
		Duel.SpecialSummon(tg,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
