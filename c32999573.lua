--エクシーズ・オーバーライド
-- 效果：
-- 场上的超量怪兽把那超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把1张手卡里侧表示从游戏中除外。这个效果双方1回合只能使用1次。
function c32999573.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上的超量怪兽把那超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把1张手卡里侧表示从游戏中除外。这个效果双方1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32999573,0))  --"是否要使用「超量超控」的效果？"
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c32999573.rcon)
	e2:SetOperation(c32999573.rop)
	c:RegisterEffect(e2)
end
-- 该行是代替取除超量素材效果的发动条件：1) 超量超控上不存在对应玩家（ep）本回合已使用过该效果的标识；2) 原素材取除是作为效果发动的代价（REASON_COST）；3) 发动素材取除的效果是已发动的超量怪兽效果；4) 该超量怪兽的超量素材数不少于本次取除数量减1；5) 当前玩家（tp）手牌中至少存在1张可以里侧表示除外的卡。
function c32999573.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(32999573+ep)==0
		and bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and re:GetHandler():GetOverlayCount()>=ev-1
		-- 检查当前玩家（tp）手牌中是否存在至少1张可以被里侧表示从游戏中除外的卡，有则满足代替素材的可用条件。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN)
end
-- 该行是代替取除超量素材效果的实际处理：先在超量超控上为对应玩家（ep）注册本回合已使用过该效果的标识（结束阶段重置），然后提示选择要除外的卡，再从当前玩家（tp）手牌中选择1张可里侧除外的卡，最后将这张卡里侧表示除外以代替本次超量素材的取除，并返回是否成功。
function c32999573.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(32999573+ep,RESET_PHASE+PHASE_END,0,1)
	-- 给玩家发送选择提示，提示内容是“请选择要除外的卡”，用于引导接下来选择要代替素材除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家（tp）从自己的手牌中选择1张可以被里侧表示除外的卡，作为本次代替超量素材去除而除外的手牌。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil,tp,POS_FACEDOWN)
	-- 将选择的手卡以里侧表示除外（REASON_COST），完成对超量素材取除的代替；返回值表示是否成功进行了代替。
	return Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
