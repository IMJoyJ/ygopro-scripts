--屍界塔フィニステラ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有10星怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合，以场上1张表侧表示卡为对象才能发动。这个回合，那张卡不会被效果破坏。
local s,id,o=GetID()
-- 创建并注册两个效果：e1作为手卡中的特殊召唤规则效果，e2作为被送去墓地时的诱发选发效果，赋予场上表侧表示卡本回合不被效果破坏的抗性。
function s.initial_effect(c)
	-- ①：自己场上有10星怪兽存在的场合，这张卡可以从手卡特殊召唤。这个卡名的①的方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以场上1张表侧表示卡为对象才能发动。这个回合，那张卡不会被效果破坏。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.indestg)
	e2:SetOperation(s.indesop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定卡片是否为表侧表示且等级为10，用于检索自己场上的10星怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsLevel(10)
end
-- 特殊召唤手续的条件：若c为nil则允许规则调用；否则检查自己主要怪兽区是否有空位，且自己场上有表侧表示10星怪兽存在。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在可用的空格，确保这张卡能从手卡特殊召唤到场上。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示且等级为10的怪兽，满足①的特殊召唤条件。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动条件和对象选择处理：在发动时确认场上存在表侧表示卡可选，并选择其中1张作为对象；连锁处理时验证对象仍在场上且表侧表示。
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动条件判定：确认场上存在至少1张表侧表示卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示，要求选择1张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方场上选择1张表侧表示卡作为这张卡②效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理：获取对象卡，若对象仍与该效果关联，则给它注册一个不会被效果破坏的持续效果，直到回合结束。
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那张卡不会被效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
