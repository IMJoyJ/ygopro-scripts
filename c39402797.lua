--トライデント・ドラギオン
-- 效果：
-- 龙族调整＋调整以外的龙族怪兽1只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：这张卡同调召唤时，以自己场上最多2张其他卡为对象才能发动。那些自己的卡破坏。这张卡在这个回合在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
function c39402797.initial_effect(c)
	-- 为这张卡添加同调召唤手续，素材要求为龙族调整1只＋调整以外的龙族怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件：仅允许以同调召唤方式特殊召唤，其他方式不能特殊召唤。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡同调召唤时，以自己场上最多2张其他卡为对象才能发动。那些自己的卡破坏。这张卡在这个回合在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39402797,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c39402797.descon)
	e2:SetTarget(c39402797.destg)
	e2:SetOperation(c39402797.desop)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件：判断这张卡是否是以同调召唤方式特殊召唤成功，只有同调召唤成功时才满足发动条件。
function c39402797.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果②的发动时处理：选自己场上除这张卡以外的最多2张卡作为对象，并设置对应的破坏操作信息。
function c39402797.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 发动合法性检查：确认自己场上除这张卡以外至少存在1张可选卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 让玩家在选择破坏对象时显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从自己场上选择1～2张除这张卡以外的卡作为效果对象并锁定。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,2,e:GetHandler())
	-- 将本次连锁要破坏的对象组及数量写入操作信息，供相关效果（如星尘龙等）进行判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②处理时：取出仍与效果相关的对象卡并破坏，若这张卡仍在场上且表侧表示，则根据破坏数量赋予本回合额外攻击次数。
function c39402797.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁操作信息中的对象卡，并筛选出仍与此效果相关（未被离场重置联系）的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local c=e:GetHandler()
	-- 用效果破坏取到的对象卡，ct记录实际被破坏的数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡在这个回合在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
