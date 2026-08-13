--天照大神
-- 效果：
-- 这张卡不能召唤·特殊召唤。
-- ①：里侧表示的这只怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡变成表侧守备表示才能发动。自己从卡组抽1张。
-- ②：这张卡反转的场合发动。这张卡以外的场上的卡全部除外。
-- ③：这张卡反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c20073910.initial_effect(c)
	-- 为这张卡添加灵魂怪兽回手效果：发生反转的回合结束时，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_FLIP)
	-- 这张卡不能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e1)
	-- 这张卡不能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为false，使这张卡永远无法通过特殊召唤上场，实现‘不能特殊召唤’的效果。
	e2:SetValue(aux.FALSE)
	c:RegisterEffect(e2)
	-- ①：里侧表示的这只怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡变成表侧守备表示才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c20073910.condition)
	e3:SetCost(c20073910.cost)
	e3:SetTarget(c20073910.target)
	e3:SetOperation(c20073910.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡反转的场合发动。这张卡以外的场上的卡全部除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP)
	e4:SetTarget(c20073910.thtg)
	e4:SetOperation(c20073910.thop)
	c:RegisterEffect(e4)
end
-- 判定①效果的发动条件：必须是对方发动的、以这张里侧表示的怪兽为对象的魔法·陷阱·怪兽效果，且该效果带有取对象标志，并确认对象包含此卡且此卡为里侧表示。
function c20073910.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中该效果所选择的对象卡集合，用于判断这张卡是否作为对象被选中。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(e:GetHandler()) and e:GetHandler():IsFacedown()
end
-- ①效果的发动代价：将这张卡从里侧表示变为表侧守备表示；chk为0时仅进行合法检查并返回true。
function c20073910.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把这张卡的表示形式变更为表侧守备表示，作为①效果的发动代价。
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- ①效果的目标处理：确认自己可以抽1张卡，然后将目标玩家设为自己、抽卡数量设为1，并注册抽卡的操作信息。
function c20073910.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法检查阶段，判断自己是否能够抽1张卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将①效果的对象玩家设定为自己，表示最终由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将①效果的对象参数设为1，表示抽卡数为1张。
	Duel.SetTargetParam(1)
	-- 注册①效果的抽卡操作信息：效果分类为抽卡，目标为自己，抽1张，供其他效果（如星尘龙、王家长眠之谷）进行检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理①效果：从连锁信息中取出目标玩家和抽卡数量，让该玩家以效果原因抽取对应数量的卡。
function c20073910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中读取之前设置的目标玩家和抽卡数量，分别保存到p和d中。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡，完成①效果的抽卡动作。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②效果的目标处理：获取这张卡以外的场上所有可以被除外的卡，并注册除外操作信息，准备全部除外。
function c20073910.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取这张卡以外的场上（怪兽区和魔法陷阱区）所有满足可被除外条件的卡集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 注册②效果的除外操作信息：分类为除外，对象为这些卡，数量为卡组数量，不指定目标玩家和位置。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 处理②效果：实际再次获取场上除这张卡以外的所有可除外卡，并将其全部除外。
function c20073910.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次取得场上除这张卡以外的所有可以被除外的卡集合（用aux.ExceptThisCard排除自身）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将上述卡集合以表侧表示形式除外，完成②效果的除外处理。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
