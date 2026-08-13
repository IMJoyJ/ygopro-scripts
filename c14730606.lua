--アイヴィ・シャックル
-- 效果：
-- 只要这张卡在场上存在，对方场上表侧表示存在的全部怪兽只在自己回合变成植物族。场上表侧表示存在的这张卡被对方的效果破坏送去墓地时，从自己卡组抽1张卡。
function c14730606.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，对方场上表侧表示存在的全部怪兽只在自己回合变成植物族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetCondition(c14730606.raccon)
	e2:SetValue(RACE_PLANT)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡被对方的效果破坏送去墓地时，从自己卡组抽1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14730606,0))  --"抽卡"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c14730606.drcon)
	e3:SetTarget(c14730606.drtg)
	e3:SetOperation(c14730606.drop)
	c:RegisterEffect(e3)
end
-- 该函数为‘自己回合’条件判断：当前回合玩家是这张卡的控制者时返回true，使种族变更效果只在己方回合适用。
function c14730606.raccon(e)
	-- 判断当前回合玩家是否等于效果的控制者，即只在效果持有者的回合时才成立。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 该函数判断送墓诱发效果的触发条件：这张卡从场上表侧表示存在时，被对方发动的效果破坏并送去墓地，且此前的控制者为自己，满足才可发动抽卡效果。
function c14730606.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and rp==1-tp
end
-- 该函数为抽卡效果的目标设定：无需选择对象，设定抽卡玩家为自己、抽卡数量为1，并登记抽卡类操作信息。
function c14730606.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为效果发动者（自己），表示抽卡玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：效果分类为抽卡（CATEGORY_DRAW），目标玩家为tp，目标组为nil，抽卡数由参数1指定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 该函数为抽卡效果的处理：从连锁信息中取得抽卡玩家和抽卡数，执行抽卡。
function c14730606.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中保存的对象玩家和对象参数，分别赋值给p和d，即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽取d张卡，即实际执行抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
