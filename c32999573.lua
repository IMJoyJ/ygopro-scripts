--エクシーズ・オーバーライド
-- 效果：
-- 场上的超量怪兽把那超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把1张手卡里侧表示从游戏中除外。这个效果双方1回合只能使用1次。
function c32999573.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个用于代替超量素材去除的效果，允许在超量怪兽发动效果时使用手卡除外代替1个超量素材
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
-- 检查是否可以发动此效果：该玩家未在本回合使用过此效果，且是因为支付代价而去除超量素材，且是超量怪兽发动的效果，且该超量怪兽的超量素材数量大于等于需要去除的数量，且该玩家手牌中有可除外的卡
function c32999573.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(32999573+ep)==0
		and bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and re:GetHandler():GetOverlayCount()>=ev-1
		-- 检查玩家手牌中是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN)
end
-- 执行效果：记录本回合已使用此效果，并提示玩家选择1张手卡里侧表示从游戏中除外
function c32999573.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(32999573+ep,RESET_PHASE+PHASE_END,0,1)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张手卡里侧表示从游戏中除外
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil,tp,POS_FACEDOWN)
	-- 将选中的卡以里侧表示从游戏中除外，作为超量素材的代替
	return Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
