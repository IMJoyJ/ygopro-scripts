--ハーピィの羽根吹雪
-- 效果：
-- 自己场上有「鹰身」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上有鸟兽族·风属性怪兽存在的场合才能发动。直到回合结束时，对方发动的怪兽的效果无效化。
-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地选1张「鹰身女妖的羽毛扫」加入手卡。
function c87639778.initial_effect(c)
	-- ①：自己场上有鸟兽族·风属性怪兽存在的场合才能发动。直到回合结束时，对方发动的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c87639778.condition)
	e1:SetTarget(c87639778.target)
	e1:SetOperation(c87639778.activate)
	c:RegisterEffect(e1)
	-- 自己场上有「鹰身」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87639778,1))  --"适用「鹰身女妖的羽毛吹雪」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c87639778.handcon)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地选1张「鹰身女妖的羽毛扫」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87639778,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c87639778.thcon)
	e3:SetTarget(c87639778.thtg)
	e3:SetOperation(c87639778.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的鸟兽族·风属性怪兽
function c87639778.disfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果①的发动条件：自己场上有鸟兽族·风属性怪兽存在
function c87639778.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的鸟兽族·风属性怪兽
	return Duel.IsExistingMatchingCard(c87639778.disfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动靶向：检查本回合是否尚未发动过此效果
function c87639778.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家本回合是否未注册过该卡的效果标识（确保一回合只能发动一次）
	if chk==0 then return Duel.GetFlagEffect(tp,87639778)==0 end
end
-- 效果①的效果处理：注册一个在连锁处理时使对方怪兽效果无效的全局效果
function c87639778.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到回合结束时，对方发动的怪兽的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetCondition(c87639778.discon)
	e1:SetOperation(c87639778.disop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将使对方怪兽效果无效的全局效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
	-- 为当前玩家注册一个持续到回合结束的效果标识，用于限制每回合的发动
	Duel.RegisterFlagEffect(tp,87639778,RESET_PHASE+PHASE_END,0,1)
end
-- 无效化效果的触发条件：对方发动的怪兽效果
function c87639778.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
end
-- 无效化效果的操作：使该连锁的效果无效
function c87639778.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对应连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 过滤条件：场上表侧表示的「鹰身」怪兽
function c87639778.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x64)
end
-- 手卡发动效果的允许条件：自己场上有「鹰身」怪兽存在
function c87639778.handcon(e)
	-- 检查自己场上是否存在表侧表示的「鹰身」怪兽
	return Duel.IsExistingMatchingCard(c87639778.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动条件：魔法与陷阱区域的这张卡被对方的效果破坏的场合
function c87639778.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤条件：卡组或墓地中的「鹰身女妖的羽毛扫」且能加入手牌
function c87639778.thfilter(c)
	return c:IsCode(18144506) and c:IsAbleToHand()
end
-- 效果②的发动靶向：检查并设置检索「鹰身女妖的羽毛扫」的操作信息
function c87639778.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在至少1张「鹰身女妖的羽毛扫」
	if chk==0 then return Duel.IsExistingMatchingCard(c87639778.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息为：从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理：从卡组或墓地选1张「鹰身女妖的羽毛扫」加入手牌
function c87639778.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择卡片加入手牌的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张不受「王家长眠之谷」影响的「鹰身女妖的羽毛扫」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c87639778.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
