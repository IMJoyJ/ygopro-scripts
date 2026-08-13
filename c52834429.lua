--オーロラの天気模様
-- 效果：
-- ①：「极光之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●只让卡1张加入自己或者对方的手卡时，把这张卡除外才能发动。加入手卡的那张卡除外，那个玩家从卡组抽1张。
function c52834429.initial_effect(c)
	c:SetUniqueOnField(1,0,52834429)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。●只让卡1张加入自己或者对方的手卡时，把这张卡除外才能发动。加入手卡的那张卡除外，那个玩家从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52834429,0))  --"加入手卡的那张卡除外并抽卡（极光之天气模样）"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c52834429.rmcon)
	-- 设置效果发动代价：将拥有该效果的「天气」怪兽自身除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c52834429.rmtg)
	e2:SetOperation(c52834429.rmop)
	-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c52834429.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 筛选可以享有效果的怪兽：自己场上主要怪兽区域（非额外区）中，与这张卡相同纵列或相邻纵列存在的「天气」效果怪兽。
function c52834429.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 触发条件：只有1张卡加入手卡时才满足“只让卡1张加入手卡”的发动条件。
function c52834429.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1
end
-- 发动时检查加入手卡的那张卡是否可被除外且其控制者能否抽1张；通过后将其记录为对象，并设定目标玩家、抽卡数量及除外/抽卡的操作信息。
function c52834429.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	-- 合法判定：加入手卡的那张卡必须能够被除外，且其控制者能够抽1张卡，否则不能发动。
	if chk==0 then return ec and ec:IsAbleToRemove() and Duel.IsPlayerCanDraw(ec:GetControler(),1) end
	local p=ec:GetControler()
	-- 将连锁的目标玩家设为加入手卡那张卡的控制者，效果处理时由该玩家抽卡。
	Duel.SetTargetPlayer(p)
	-- 将连锁的目标参数设为1，即抽卡数量为1张。
	Duel.SetTargetParam(1)
	e:SetLabelObject(ec)
	ec:CreateEffectRelation(e)
	-- 向对手玩家提示“对方选择了：极光之天气模样的效果”，展示该效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记操作信息：将加入手卡的那张卡确定为除外对象（1张）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,ec,1,0,0)
	-- 登记操作信息：让目标玩家抽1张卡（抽卡对象在处理时确定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,1)
end
-- 效果处理时，若记录的卡片仍与效果关联，则将其除外；除外成功后，使目标玩家抽1张卡。
function c52834429.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 从当前连锁信息中取出目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以表侧表示将那张加入手卡的卡除外；若除外成功（返回值大于0），则继续执行抽卡。
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 让目标玩家抽1张卡，抽卡原因为效果。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
