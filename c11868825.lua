--ゴブリンの秘薬
-- 效果：
-- ①：自己回复600基本分。
function c11868825.initial_effect(c)
	-- ①：自己回复600基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11868825.rectg)
	e1:SetOperation(c11868825.recop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理函数：检查发动条件（无特殊要求，允许发动），并登记回复对象为自己、回复数值为600，同时设置操作信息以表明本效果属于回复基本分的效果。
function c11868825.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为发动者tp，即指定回复基本分的玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设置为600，即指定回复基本分的数值。
	Duel.SetTargetParam(600)
	-- 登记操作信息：本连锁的效果属于CATEGORY_RECOVER（回复基本分），预计使玩家tp回复600点基本分，用于后续的时点检测与效果互动。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end
-- 效果处理时的操作函数：从连锁信息中取出目标玩家和回复数值，并执行对应的基本分回复。
function c11868825.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和目标参数，分别存入局部变量p和d，作为回复对象和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT（效果原因）让玩家p回复d点基本分，即实际执行“回复600基本分”的处理。
	Duel.Recover(p,d,REASON_EFFECT)
end
