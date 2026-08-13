--マジック・リアクター・AID
-- 效果：
-- 对方把魔法卡发动时才能发动。把那张魔法卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c15175429.initial_effect(c)
	-- 对方把魔法卡发动时才能发动。把那张魔法卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15175429,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c15175429.condition)
	e1:SetTarget(c15175429.target)
	e1:SetOperation(c15175429.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：对方玩家发动魔法卡（发动者不是本卡控制者，且该连锁为魔法卡或陷阱卡的发动，并且该卡为魔法卡）才能发动。
function c15175429.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 发动时判定：在效果发动确认阶段，检查对方发动的魔法卡是否可被破坏；若可以，则设置本连锁的操作信息为破坏那张魔法卡，并预定向对方造成800点伤害。
function c15175429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置操作信息：声明本效果将破坏连锁中的魔法卡，对象为当前发动的卡片(eg)，数量1，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 设置操作信息：声明本效果将对对方玩家造成800点伤害，对象玩家为对方(1-tp)。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理：若对方发动的魔法卡仍与连锁关联，则将其破坏；若破坏成功，则给对方玩家造成800点伤害。
function c15175429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理条件判断：确认对方发动的魔法卡仍与当前效果关联且已被成功破坏（Destroy返回值不为0），才能执行后续伤害。
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 给对方玩家造成800点效果伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
