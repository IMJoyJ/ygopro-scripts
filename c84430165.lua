--海晶乙女潮流
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己的「海晶少女」连接怪兽战斗破坏对方怪兽时才能发动。给与对方那只自己怪兽的连接标记数量×400伤害。自己场上有连接2以上的「海晶少女」怪兽存在，破坏对方连接怪兽的场合，再给与对方破坏的怪兽的连接标记数量×500伤害。
function c84430165.initial_effect(c)
	-- ①：自己的「海晶少女」连接怪兽战斗破坏对方怪兽时才能发动。给与对方那只自己怪兽的连接标记数量×400伤害。自己场上有连接2以上的「海晶少女」怪兽存在，破坏对方连接怪兽的场合，再给与对方破坏的怪兽的连接标记数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCountLimit(1,84430165+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c84430165.target)
	e1:SetOperation(c84430165.activate)
	c:RegisterEffect(e1)
	-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84430165,0))  --"适用「海晶少女潮流」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c84430165.handcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：属于自己控制的「海晶少女」连接怪兽
function c84430165.afilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
-- 效果发动时的目标确认：检查是否有自己的「海晶少女」连接怪兽战斗破坏了怪兽
function c84430165.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c84430165.afilter,1,nil,tp) end
end
-- 过滤条件：自己场上表侧表示的连接2以上的「海晶少女」怪兽
function c84430165.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(2)
end
-- 效果处理：给与对方自己怪兽连接标记数量×400的伤害，若满足条件则再给与对方被破坏怪兽连接标记数量×500的伤害
function c84430165.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=eg:Filter(c84430165.afilter,nil,tp):GetFirst()
	local bc=a:GetBattleTarget()
	local dam=a:GetLink()
	if dam<0 then dam=0 end
	-- 给与对方那只自己怪兽的连接标记数量×400的伤害
	Duel.Damage(1-tp,dam*400,REASON_EFFECT)
	-- 判断自己场上是否存在连接2以上的「海晶少女」怪兽，且被破坏的对方怪兽是否为连接怪兽
	if Duel.IsExistingMatchingCard(c84430165.cfilter,tp,LOCATION_MZONE,0,1,nil) and bc:IsType(TYPE_LINK) then
		local dam1=bc:GetLink()
		-- 中断当前效果，使后续的追加伤害处理不与前一次伤害同时处理
		Duel.BreakEffect()
		-- 给与对方被破坏怪兽的连接标记数量×500的伤害
		Duel.Damage(1-tp,dam1*500,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的连接3以上的「海晶少女」怪兽
function c84430165.hcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(3)
end
-- 手卡发动条件：自己场上存在连接3以上的「海晶少女」怪兽
function c84430165.handcon(e)
	-- 检查自己场上是否存在满足条件的连接3以上的「海晶少女」怪兽
	return Duel.IsExistingMatchingCard(c84430165.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
