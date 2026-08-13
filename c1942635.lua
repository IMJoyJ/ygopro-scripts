--王の報酬
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有衍生物存在，对方不能选择「王战」效果怪兽作为攻击对象。
-- ②：「王战」效果怪兽被战斗破坏的场合发动。对方从卡组抽1张。
function c1942635.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有衍生物存在，对方不能选择「王战」效果怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	-- 设置①效果的适用条件：自己场上有衍生物存在时，该封锁攻击对象的效果才适用。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(c1942635.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：「王战」效果怪兽被战斗破坏的场合发动。对方从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1942635,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,1942635)
	e3:SetCondition(c1942635.drcon)
	e3:SetTarget(c1942635.drtg)
	e3:SetOperation(c1942635.drop)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为表侧表示且属于「王战」字段的效果怪兽，此类怪兽不能被对方选择为攻击对象。
function c1942635.atkval(e,c)
	return c:IsFaceup() and c:IsSetCard(0x134) and c:IsType(TYPE_EFFECT)
end
-- 筛选被战斗破坏的怪兽：其在场上的原种类包含效果怪兽，且原卡名属于「王战」字段。
function c1942635.cfilter(c)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_EFFECT)~=0 and c:IsPreviousSetCard(0x134)
end
-- ②的发动条件：本次被战斗破坏的怪兽中存在至少1只符合cfilter条件的「王战」效果怪兽。
function c1942635.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1942635.cfilter,1,nil)
end
-- ②发动时的处理：无额外发动限制，将对象玩家设为对方，抽卡张数设为1，并登记对方抽卡的操作信息。
function c1942635.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设置为对方（1-tp），即之后抽卡的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设置为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置效果处理时的操作信息：进行抽卡分类，目标玩家为对方，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- ②的效果处理：从连锁信息中取得对象玩家和抽卡张数，令对方抽出对应数量的卡。
function c1942635.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出先前设置的对象玩家p和对象参数d（抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，即对方抽1张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
