--トライデント・ドラギオン
-- 效果：
-- 龙族调整＋调整以外的龙族怪兽1只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：这张卡同调召唤时，以自己场上最多2张其他卡为对象才能发动。那些自己的卡破坏。这张卡在这个回合在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
function c39402797.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（龙族）和1只以上调整以外的龙族怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过同调召唤方式特殊召唤
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
-- 判断此卡是否为同调召唤方式特殊召唤成功
function c39402797.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 选择最多2张自己场上的卡作为破坏对象
function c39402797.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 检查是否满足选择破坏对象的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1~2张自己场上的卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,2,e:GetHandler())
	-- 设置连锁操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果并根据破坏数量增加攻击次数
function c39402797.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择破坏的卡，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local c=e:GetHandler()
	-- 将选择的卡按效果破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使此卡在本回合的战斗阶段中，除了通常攻击外，可以再进行最多破坏卡数量的攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
