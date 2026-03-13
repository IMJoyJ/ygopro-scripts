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
	-- 效果原文内容：●只让卡1张加入自己或者对方的手卡时，把这张卡除外才能发动。加入手卡的那张卡除外，那个玩家从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52834429,0))  --"加入手卡的那张卡除外并抽卡（极光之天气模样）"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c52834429.rmcon)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c52834429.rmtg)
	e2:SetOperation(c52834429.rmop)
	-- 效果原文内容：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c52834429.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为天气族效果怪兽且位于与极光之天气模样同一纵列或相邻纵列
function c52834429.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 判断加入手卡的卡片数量是否为1张
function c52834429.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1
end
-- 设置效果的目标玩家和抽卡数量，并设定操作信息
function c52834429.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	-- 检查是否满足除外目标卡和抽卡的条件
	if chk==0 then return ec and ec:IsAbleToRemove() and Duel.IsPlayerCanDraw(ec:GetControler(),1) end
	local p=ec:GetControler()
	-- 设置连锁处理的目标玩家
	Duel.SetTargetPlayer(p)
	-- 设置连锁处理的目标参数（抽卡数量）
	Duel.SetTargetParam(1)
	e:SetLabelObject(ec)
	ec:CreateEffectRelation(e)
	-- 向对方提示发动了此效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置将目标卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,ec,1,0,0)
	-- 设置目标玩家抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,1)
end
-- 执行效果处理：若目标卡被成功除外，则该玩家从卡组抽一张卡
function c52834429.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 尝试将目标卡除外
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 若目标卡被成功除外，则让对应玩家抽一张卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
